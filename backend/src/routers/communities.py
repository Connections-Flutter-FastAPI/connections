# backend/routers/communities.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
import psycopg2

from .. import schemas, crud, auth, utils
from ..database import get_db_connection

router = APIRouter(
    prefix="/communities",
    tags=["Communities"],
)

@router.post("", status_code=status.HTTP_201_CREATED, response_model=schemas.CommunityDisplay)
async def create_community(
    community_data: schemas.CommunityCreate,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Creates a new community."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Format location string if needed, assume input is "(lon,lat)"
        # db_location_str = utils.format_location_for_db(community_data.primary_location)
        db_location_str = community_data.primary_location # Use directly if format is correct

        community_id = crud.create_community_db(
            cursor,
            name=community_data.name,
            description=community_data.description,
            created_by=current_user_id,
            primary_location_str=db_location_str,
            interest=community_data.interest
        )
        if community_id is None:
            # This might happen if ON CONFLICT DO NOTHING occurred, but RETURNING id should still work.
            # More likely indicates an unexpected DB issue.
            raise HTTPException(status_code=500, detail="Community creation failed")

        # Fetch the created community details to return
        created_community_db = crud.get_community_details_db(cursor, community_id) # Use details query
        conn.commit()

        if not created_community_db:
             raise HTTPException(status_code=500, detail="Could not retrieve created community details")

        # Process location for display
        location_str = created_community_db.get('primary_location')
        processed_data = dict(created_community_db)
        processed_data['primary_location'] = str(location_str) if location_str else None # Return as string

        print(f"✅ Community '{community_data.name}' (ID: {community_id}) created by User {current_user_id}")
        return schemas.CommunityDisplay(**processed_data)

    except psycopg2.IntegrityError:
        if conn: conn.rollback()
        # Could be unique name violation or FK violation (if user doesn't exist)
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Community name may already exist or invalid data provided.")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error creating community: {e}")
        raise HTTPException(status_code=500, detail=f"Could not create community: {e}")
    finally:
        if conn: conn.close()

@router.get("", response_model=List[schemas.CommunityDisplay])
async def get_communities():
    """Fetches a list of all communities."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        communities_db = crud.get_communities_db(cursor)

        processed_communities = []
        for comm in communities_db:
            data = dict(comm)
            loc_str = comm.get('primary_location')
            data['primary_location'] = str(loc_str) if loc_str else None
            # Add online_count (defaults to 0 if not present in this query)
            data['online_count'] = data.get('online_count', 0)
            processed_communities.append(data)

        print(f"✅ Fetched {len(processed_communities)} communities")
        return processed_communities # FastAPI validates list items
    except Exception as e:
        print(f"❌ Error fetching communities: {e}")
        raise HTTPException(status_code=500, detail="Error fetching communities")
    finally:
        if conn: conn.close()

@router.get("/trending", response_model=List[schemas.CommunityDisplay])
async def get_trending_communities():
    """Fetches trending communities."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        communities_db = crud.get_trending_communities_db(cursor)
        processed_communities = []
        for comm in communities_db:
             data = dict(comm)
             loc_str = comm.get('primary_location')
             data['primary_location'] = str(loc_str) if loc_str else None
             # Add online_count (defaults to 0 if not present in this query)
             data['online_count'] = data.get('online_count', 0)
             processed_communities.append(data)

        print(f"✅ Fetched {len(processed_communities)} trending communities")
        return processed_communities
    except Exception as e:
        print(f"❌ Error fetching trending communities: {e}")
        raise HTTPException(status_code=500, detail="Error fetching trending communities")
    finally:
        if conn: conn.close()


@router.get("/{community_id}/details", response_model=schemas.CommunityDisplay)
async def get_community_details(community_id: int):
    """Fetches details for a specific community."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        community_db = crud.get_community_details_db(cursor, community_id)
        if not community_db:
             raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found")

        data = dict(community_db)
        loc_str = community_db.get('primary_location')
        data['primary_location'] = str(loc_str) if loc_str else None

        print(f"✅ Details fetched for community {community_id}")
        return schemas.CommunityDisplay(**data)
    except Exception as e:
        print(f"❌ Error fetching community details {community_id}: {e}")
        raise HTTPException(status_code=500, detail="Error fetching community details")
    finally:
        if conn: conn.close()


@router.delete("/{community_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_community(
    community_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Deletes a community (only creator can delete)."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Check ownership
        community = crud.get_community_by_id(cursor, community_id)
        if not community:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found")
        if community["created_by"] != current_user_id:
             raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this community")

        rows_deleted = crud.delete_community_db(cursor, community_id)
        conn.commit()

        if rows_deleted == 0:
            print(f"⚠️ Community {community_id} not found during delete (race condition?).")
            # Already checked owner, so 404 is appropriate if it disappeared
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found")

        print(f"✅ Community {community_id} deleted by User {current_user_id}")
        return None
    except HTTPException as http_exc:
         if conn: conn.rollback()
         raise http_exc
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error deleting community {community_id}: {e}")
        raise HTTPException(status_code=500, detail="Could not delete community")
    finally:
        if conn: conn.close()

@router.post("/{community_id}/join", status_code=status.HTTP_200_OK)
async def join_community(
    community_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Allows the current user to join a community."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        member_id = crud.join_community_db(cursor, current_user_id, community_id)
        conn.commit()
        if member_id:
            return {"message": "Joined community successfully"}
        else:
            # User was already a member (ON CONFLICT DO NOTHING)
            return {"message": "Already a member"}
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error joining community {community_id} for user {current_user_id}: {e}")
        # Could be FK violation if community_id is invalid
        raise HTTPException(status_code=400, detail=f"Could not join community: {e}")
    finally:
        if conn: conn.close()

@router.delete("/{community_id}/leave", status_code=status.HTTP_200_OK)
async def leave_community(
    community_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Allows the current user to leave a community."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        deleted_id = crud.leave_community_db(cursor, current_user_id, community_id)
        conn.commit()
        if deleted_id:
            return {"message": "Left community successfully"}
        else:
            # User was not a member
            return {"message": "Not a member of this community"}
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error leaving community {community_id} for user {current_user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Could not leave community: {e}")
    finally:
        if conn: conn.close()


# --- Community Post Management (TODO: Add permission checks) ---

@router.post("/{community_id}/add_post/{post_id}", status_code=status.HTTP_201_CREATED)
async def add_post_to_community(
    community_id: int,
    post_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Links an existing post to a community."""
    # TODO: Add permission check (e.g., is user a member/moderator?)
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        link_id = crud.add_post_to_community_db(cursor, community_id, post_id)
        conn.commit()
        if link_id:
            return {"message": "Post added to community"}
        else:
            return {"message": "Post already in community or invalid IDs"}
    except psycopg2.IntegrityError:
         if conn: conn.rollback()
         raise HTTPException(status_code=404, detail="Community or Post not found")
    except Exception as e:
        if conn: conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()

@router.delete("/{community_id}/remove_post/{post_id}", status_code=status.HTTP_200_OK)
async def remove_post_from_community(
    community_id: int,
    post_id: int,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Unlinks a post from a community."""
    # TODO: Add permission check (e.g., is user moderator or post author?)
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        deleted_id = crud.remove_post_from_community_db(cursor, community_id, post_id)
        conn.commit()
        if deleted_id:
            return {"message": "Post removed from community"}
        else:
            return {"message": "Post was not found in this community"}
    except Exception as e:
        if conn: conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()


# --- Event routes scoped under community ---

@router.post("/{community_id}/events", status_code=status.HTTP_201_CREATED, response_model=schemas.EventDisplay)
async def create_event_in_community(
    community_id: int,
    event_data: schemas.EventCreate,
    current_user_id: int = Depends(auth.get_current_user)
):
    """Creates a new event within a specific community."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # TODO: Optional: Check if user is member/admin of the community before allowing creation
        event_info = crud.create_event_db(
            cursor,
            community_id=community_id,
            creator_id=current_user_id,
            title=event_data.title,
            description=event_data.description,
            location=event_data.location,
            event_timestamp=event_data.event_timestamp,
            max_participants=event_data.max_participants,
            image_url=event_data.image_url
        )
        if not event_info:
             raise HTTPException(status_code=500, detail="Event creation failed")

        conn.commit()
        event_id = event_info['id']
        created_at = event_info['created_at']
        print(f"✅ Event {event_id} created in community {community_id} by user {current_user_id}")

        # Return the full EventDisplay structure
        return schemas.EventDisplay(
            id=event_id,
            community_id=community_id,
            creator_id=current_user_id,
            created_at=created_at,
            participant_count=1, # Creator is the first participant
            **event_data.dict() # Include fields from EventCreate
        )
    except psycopg2.Error as e:
        if conn: conn.rollback()
        print(f"❌ DB Error creating event: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {e.pgerror}")
    except Exception as e:
        if conn: conn.rollback()
        print(f"❌ Error creating event: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if conn: conn.close()

@router.get("/{community_id}/events", response_model=List[schemas.EventDisplay])
async def list_community_events(community_id: int):
    """Lists events for a specific community."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        events_db = crud.get_events_for_community_db(cursor, community_id)
        print(f"✅ Fetched {len(events_db)} events for community {community_id}")
        # FastAPI validates list items against EventDisplay
        return events_db
    except Exception as e:
        print(f"❌ Error fetching community events {community_id}: {e}")
        raise HTTPException(status_code=500, detail="Error fetching events")
    finally:
        if conn: conn.close()
