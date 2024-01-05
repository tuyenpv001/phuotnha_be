import { Server } from 'socket.io'

import {
  updateOfflineUser,
  updateOnlineUser,
} from '../controllers/user_controller'
import { verifyTokenSocket } from '../middleware/verify_token'
import { InsertListChatTrip, addNewMessageTrip, updateLastMessageTrip } from '../controllers/chat_controller'

export const socketChatMessagesTrip = (io: Server) => {
  const nameSpaceChat = io.of('/socket-chat-message-trip')

  nameSpaceChat.on('connection', async client => {
    const [verify, uidPerson] = verifyTokenSocket(
      client.handshake.headers['xxx-token']
    )

    if (!verify) {
      return client.disconnect()
    }

    console.log('TRIP CONECTED')

    client.join(uidPerson)

    client.on('message-trip', async payload => {
      console.log(payload)

      await InsertListChatTrip(payload.from, payload.to)

      await updateLastMessageTrip(payload.to, payload.from, payload.message)

      await addNewMessageTrip(payload.from, payload.to, payload.message)

      nameSpaceChat.to(payload.to).emit('message-trip', payload)
    })

    
    client.on('disconnect', async _ => {
      console.log('USER DISCONNECT')
    })
  })
}
