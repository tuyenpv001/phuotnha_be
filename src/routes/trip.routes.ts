import { Router } from 'express';
import { verifyToken } from '../middleware/verify_token';
import * as trip from '../controllers/trip_controller';
import { uploadsTrip } from '../lib/multer';


const router = Router();

    router.post('/trip/create-new-trip', [ verifyToken, uploadsTrip.array('imageTrips') ], trip.createNewTrip);
    router.get('/trip/get-all-trips',verifyToken ,trip.getAllTrip)
    router.get('/trip/get-trips-schedule',verifyToken ,trip.getAllTripschedule)
    router.get(
      '/trip/get-trip-by-id/:id',
      verifyToken,
      trip.getDetailTripById
    )
    router.delete(
      '/trip/delete-trip/:id',
      verifyToken,
      trip.deleteTripById
    )
    router.get(
      '/trip/get-members-trip-by-id/:id',
      verifyToken,
      trip.getMemberTripById
    )
    router.get(
      '/trip/get-location-members-trip-by-id/:id',
      verifyToken,
      trip.getLocationAllMemberTripById
    )
    router.get(
      '/trip/get-trip-by-id-extra/:id',
      verifyToken,
      trip.getDetailExtraTripById
    )
    router.get(
      '/trip/get-trip-by-idPerson',
      verifyToken,
      trip.getTripByIdPerson
    ) 
    router.post('/trip/join-trip', verifyToken, trip.joinTripByUser)
    router.post(
      '/trip/change-status-trip',
      verifyToken,
      trip.updateStatusOfTrip
    )
    router.post('/trip/save-trip', verifyToken, trip.saveAndUnSaveTripByUser) 
    router.post('/trip/add-role-user', verifyToken, trip.addRoleForUserOfTrip)
    router.post('/trip/update-status', verifyToken, trip.updateStatusOfTrip)
    router.put('/trip/rate-trip', verifyToken, trip.addRateTrip)
    router.post('/trip/comment', verifyToken, trip.addCommentTrip)
    router.post('/trip/trip-start',verifyToken ,trip.addTripStart)
    router.get(
      '/trip/comments/:id',
      verifyToken,
      trip.getCommentsById
    )
    router.get(
      '/trip/comments-completed/:id',
      verifyToken,
      trip.getCommentsCompletedById
    )
    router.get(
      '/trip/markers/:id',
      verifyToken,
      trip.getMarkersById
    )
    router.get(
      '/trip/get-list-saved-trips',
      verifyToken,
      trip.getListSavedTripsByUser
    ) 
    router.get(
      '/trip/get-all-trips-for-search',
      verifyToken,
      trip.getAllTripsForSearch
    )
    router.post('/trip/like-or-unlike-trip', verifyToken, trip.likeOrUnLikeTrip)
    router.get(
      '/trip/get-comments-by-idtrip/:uidTrip',
      verifyToken,
      trip.getCommentsByIdTrip
    )
    router.post('/trip/add-new-comment', verifyToken, trip.addNewComment)
    router.put(
      '/trip/like-or-unlike-comment',
      verifyToken,
      trip.likeOrUnLikeComment
    )
    router.get(
      '/trip/get-all-trip-by-user-id',
      verifyToken,
      trip.getAllTripByUserID
    )
     router.get(
       '/trip/get-all-message-trip-by-id/:id',
       verifyToken,
       trip.getAllMessagesById
     )


export default router;
