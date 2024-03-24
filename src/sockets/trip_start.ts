import { Server } from 'socket.io'
import {
  addNewMessage,
  InsertListChat,
  updateLastMessage,
} from '../controllers/chat_controller'
import {
  updateOfflineUser,
  updateOnlineUser,
} from '../controllers/user_controller'
import { verifyTokenSocket } from '../middleware/verify_token'
import { getLocationAllMemberTripById, getLocationAllMemberTripByIdSocket } from '../controllers/trip_controller'

export const socketTripStarting = (io: Server) => {
  const nameSpaceChat = io.of('/socket-trip-starting')

  nameSpaceChat.on('connection', async client => {
   console.log("Connection");
   
    const [verify, uidPerson] = verifyTokenSocket(
      client.handshake.headers['xxx-token']
    )

    if (!verify) {
      return client.disconnect()
    }

    console.log('USER CONECTED')

    client.join(uidPerson)

    client.on('start-trip', async payload => {
      console.log('start trip:', payload)
      await getLocationAllMemberTripByIdSocket(payload.tripId);
      nameSpaceChat.emit('start-trip', payload);
    })

    client.on('disconnect', async _ => {
      console.log('USER DISCONNECT')
    })
  })
}
