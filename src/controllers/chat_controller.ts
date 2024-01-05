import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { connect } from '../database/connection';
import { RowDataPacket } from 'mysql2';


export const getListMessagesByUser = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const listdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_ALL_MESSAGE_BY_USER(?);`,[req.idPerson]);

        conn.end();

        return res.json({
            resp: true,
            message: 'Danh sách tin nhắn của người dùng',
            listChat: listdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }
}
export const getListMessagesByTrip = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const listdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_ALL_MESSAGE_BY_TRIP(?);`,[req.idPerson]);

        conn.end();

        return res.json({
            resp: true,
            message: 'Messenger of trip',
            listChat: listdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }
}


export const InsertListChat = async ( uidSource: string, uidTarget: string )  => {


    const conn = await connect();

    const verifyExistsSourceone = await conn.query<RowDataPacket[]>('SELECT COUNT(uid_list_chat) AS chat FROM list_chats WHERE source_uid = ? AND target_uid = ? LIMIT 1', [ uidSource, uidTarget ]);

    if( verifyExistsSourceone[0][0].chat == 0){

        await conn.query('INSERT INTO list_chats (uid_list_chat, source_uid, target_uid) VALUE (?,?,?)', [ uuidv4(), uidSource, uidTarget ]);

    }

    conn.end();

}
export const InsertListChatTrip = async ( uidSource: string, uidTarget: string )  => {

    const conn = await connect();

    const verifyExistsSourceone = await conn.query<RowDataPacket[]>(
      'SELECT COUNT(uid) AS chat FROM list_trip_chat WHERE source_uid = ? AND trip_uid = ? LIMIT 1',
      [uidSource, uidTarget]
    )

    if( verifyExistsSourceone[0][0].chat == 0){
// INSERT INTO `list_trip_chat`(`uid`, `soure_uid`, `trip_uid`, `last_message`, `update_at`) VALUES ()
        await conn.query(
          'INSERT INTO list_trip_chat (uid, source_uid, trip_uid) VALUE (?,?,?)',
          [uuidv4(), uidSource, uidTarget]
        )
    }

    conn.end();

}

export const updateLastMessage = async (uidTarget: string, uidPerson: string, message: string) => {

    const conn = await connect();

    const update = new Date().toISOString().slice(0, 19).replace('T', ' ');

   await conn.query(
     'UPDATE list_chats SET last_message = ?, updated_at = ? WHERE source_uid = ? AND target_uid = ?',
     [message, update, uidPerson, uidTarget]
   )

    conn.end();
}
export const updateLastMessageTrip = async (uidTarget: string, uidPerson: string, message: string) => {

    const conn = await connect();

    const update = new Date().toISOString().slice(0, 19).replace('T', ' ');

    await conn.query(
      'UPDATE list_trip_chat SET last_message = ?, updated_at = ? WHERE source_uid = ? AND trip_uid = ?',
      [message, update, uidPerson, uidTarget]
    )
    conn.end();
}

export const addNewMessage = async ( uidSource: string, uidTarget: string, message: string ) => {

    const conn = await connect();

    await conn.query('INSERT INTO messages (uid_messages, source_uid, target_uid, message) VALUE (?,?,?,?)', [ uuidv4(), uidSource, uidTarget, message ]);

    conn.end();
}
export const addNewMessageTrip = async ( uidSource: string, uidTarget: string, message: string ) => {

    const conn = await connect();
// `trip_messages`(`uid_message_trip`, `soure_uid`, `target_trip_uid`, `message`
    await conn.query(
      'INSERT INTO trip_messages (uid_message_trip, source_uid, target_trip_uid, message) VALUE (?,?,?,?)',
      [uuidv4(), uidSource, uidTarget, message]
    )

    conn.end();
}


export const getAllMessagesByUser = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const messagesdb = await conn.query<RowDataPacket[]>(`CALL SP_ALL_MESSAGE_BY_USER(?,?);`, [ req.idPerson, req.params.from ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'get all messages by user',
            listMessage: messagesdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}


export const getAllMessagesByTrip = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const messagesdb = await conn.query<RowDataPacket[]>(
          `CALL SP_ALL_MESSAGE_BY_TRIP(?,?);`,
          [req.idPerson, req.params.from]
        )

        conn.end();

        return res.json({
            resp: true,
            message: 'get all messages by user',
            listMessage: messagesdb[0][0]
        });

    } catch(err) {
        console.log(err);
        
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}





