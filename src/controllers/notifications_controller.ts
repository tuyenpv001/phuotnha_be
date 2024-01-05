import { Request, Response } from 'express';
import { connect } from '../database/connection';
import { RowDataPacket } from 'mysql2';
import { v4 as uuidv4 } from 'uuid';

export const getNotificationsByUser = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const notificationdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_NOTIFICATION_BY_USER(?)`, [ req.idPerson ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'Get Notifications',
            notificationsdb: notificationdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}
type Notification = 'like'|'comment'|'join'|'add_fr'|'start'|'role'|'cancel'
interface INotification {
    type: Notification,
    personSource?: string, 
    personDistination?: string, 
    postOrTripUid?: string}
export const addNotification = async (notification :INotification ) => {
    // 'like','comment','join','add_fr','start','role','cancel'
    // INSERT INTO `notifications`(`uid_notification`, `type_notification`, `created_at`, `user_uid`, `followers_uid`, `post_uid`) VALUES ('[value-1]','[value-2]','[value-3]','[value-4]','[value-5]','[value-6]')

    const conn = await connect();
    await conn.query(
      'INSERT INTO notifications (uid_notification, type_notification, user_uid, followers_uid, post_uid) VALUE (?,?,?,?,?)',
      [
        uuidv4(),
        notification.type,
        notification.personSource ?? "",
        notification.personDistination ?? '',
        notification.postOrTripUid ?? "",
      ]
    )
    conn.end();
}