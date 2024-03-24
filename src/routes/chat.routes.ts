import { Router } from 'express';
import { verifyToken } from '../middleware/verify_token';
import * as chat from '../controllers/chat_controller';

const router = Router();

    router.get('/chat/get-list-chat-by-user', verifyToken, chat.getListMessagesByUser );
    router.get('/chat/get-all-message-by-user/:from', verifyToken, chat.getAllMessagesByUser );
    router.get('/chat/get-call-by-user/:id', verifyToken, chat.getCallByUser );
    
    router.get('/chat/get-list-chat-by-trip', verifyToken, chat.getListMessagesByTrip );
    router.get('/chat/get-all-message-by-trip/:from', verifyToken, chat.getAllMessagesByTrip );
export default router;