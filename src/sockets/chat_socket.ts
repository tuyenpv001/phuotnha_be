import { Server } from 'socket.io';
import { addNewCalling, addNewMessage, addNewMessageTrip, InsertListChat, InsertListChatTrip, updateLastMessage, updateLastMessageTrip } from '../controllers/chat_controller';
import { updateOfflineUser, updateOnlineUser } from '../controllers/user_controller';
import { verifyTokenSocket } from '../middleware/verify_token';


export const socketChatMessages = ( io: Server ) =>{

    const nameSpaceChat = io.of('/socket-chat-message');
    nameSpaceChat.on('connection', async (client) => {

        const [ verify, uidPerson ] = verifyTokenSocket( client.handshake.headers['xxx-token'] );

        if( !verify ) { return client.disconnect(); }

        console.log('USER CONECTED');


        client.join( uidPerson );

        client.on('message-personal', async payload => {

            console.log(payload);

            await InsertListChat(payload.from, payload.to);

            await updateLastMessage(payload.to, payload.from, payload.message);

            await addNewMessage(payload.from, payload.to, payload.message);
            
            nameSpaceChat.to( payload.to ).emit('message-personal', payload );
        });

        client.on('message-trip', async payload => {
          console.log(payload)

          await InsertListChatTrip(payload.from, payload.to)

          await updateLastMessageTrip(payload.to, payload.from, payload.message)

          await addNewMessageTrip(payload.from, payload.to, payload.message)

          nameSpaceChat.to(payload.to).emit('message-trip', payload)
        })

        // client.on('start-trip', async payload => {
        //   console.log("start trip:",payload)

        //   console.log("Start trip");
          

        //   nameSpaceChat.to(payload.to).emit('start-trip', payload)
        // })
        

        client.on('call-video-rtc', (payload) => {
          console.log(payload);
          nameSpaceChat.to(payload.callerId).emit('accept-calling', payload)
        })



        client.on('accept-call', payload =>  {
          console.log(payload);
          
        })

        client.on('disconnect', async _ => {

            console.log('USER DISCONNECT');

        });

    });
}
