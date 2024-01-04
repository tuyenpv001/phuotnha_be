import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { connect } from '../database/connection';
import { ILikePost, INewComment, IUidComment } from '../interfaces/post.interface';
import { RowDataPacket } from 'mysql2';
import { ICommentTrip, IJoinTrip, IMemberLocation, INewTrip, IRoleTrip, ISaveTrip, IStatusTrip } from '../interfaces/trip.interface';
import { Location, haversine } from '../lib/haversine';


export const createNewTrip = async (req: Request, res: Response): Promise<Response> => {

    try {
        console.log(req.body, req.idPerson);
        
        const { trip_title, trip_description,
            trip_from,trip_to,trip_date_start,trip_date_end
            ,trip_member,trip_status,trip_schedule }: INewTrip = req.body

        const files = req.files as  Express.Multer.File[];

        const conn = await connect();

        const checkMatch = await conn.query<RowDataPacket[]>(
          'CALL SP_CHECK_DUPLICATE_TRIP(?,?,?)',
          [req.idPerson, trip_date_start, trip_date_end]
        )
          console.log(checkMatch[0]);
          console.log(checkMatch[0][0]);
          console.log(checkMatch[0][1]);
          console.log(checkMatch[0][0][0]?.countTripCreated)
          console.log(checkMatch[0][1][0]?.countTripJoined)
           if (
             checkMatch[0][0][0]?.countTripCreated !== 0 &&
             checkMatch[0][1][0]?.countTripJoined !== 0
           ) {
             return res.status(500).json({
               resp: false,
               message:
                 'Lỗi đã trùng với chuyến đi đã tạo/ chuyến đi đã tham gia',
             })
           } 
        if (checkMatch[0][0][0]?.countTripCreated !== 0) {
          return res.status(500).json({
            resp: false,
            message: 'Lỗi đã trùng với chuyến đi đã tạo',
          })
        }
        if (checkMatch[0][1][0]?.countTripJoined !== 0) {
          return res.status(500).json({
            resp: false,
            message: 'Lỗi đã trùng với chuyến đi đã tham gia',
          })
        } 
       
        

          const uidTrip = uuidv4()

          await conn.query(
            'INSERT INTO trips (uid,trip_title, trip_description,trip_from,trip_to,trip_date_start,trip_date_end,trip_member,trip_status,user_uid) value (?,?,?,?,?,?,?,?,?,?)',
            [
              uidTrip,
              trip_title,
              trip_description,
              trip_from,
              trip_to,
              trip_date_start,
              trip_date_end,
              trip_member,
              trip_status,
              req.idPerson,
            ]
          )

          files.forEach(async img => {
            await conn.query(
              'INSERT INTO trip_images (uid, trip_image_url, trip_uid) VALUES (?,?,?)',
              [uuidv4(), img.filename, uidTrip]
            )
          })

          if (trip_schedule) {
            if (trip_schedule.length !== 0) {
              trip_schedule.forEach(async detail => {
                await conn.query(
                  'INSERT INTO `trip_schedule`(`uid`, `trip_uid`, `lat`, `lng`, `address_short`, `address_detail`, `isGasStation`, `isRepairMotobike`) VALUES (?,?,?,?,?,?,?,?)',
                  [
                    uuidv4(),
                    uidTrip,
                    detail.lat,
                    detail.lng,
                    detail.address_short,
                    detail.address_detail,
                    detail.isGasStation,
                    detail.isRepairMotobike,
                  ]
                )
              })
            }
          }

          return res.json({
            resp: true,
            message: 'Trip created success',
          })
        
        
  
    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const getAllTrip = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const postdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_ALL_TRIP(?);`, [ req.idPerson ]);

        const imagesdb = postdb[0][0].testing;

        await conn.end();
        console.log(postdb[0][0])
        
        
        return res.json({
            resp: true,
            message: 'Get All trips',
            trips: postdb[0][0],
            imagesdb
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }
}

export const getAllTripschedule = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()

    const postdb = await conn.query<RowDataPacket[]>(
      `CALL SP_GET_ALL_TRIP_SCHEDULE(?);`,
      [req.idPerson]
    )

    const imagesdb = postdb[0][0].testing

    await conn.end()

    return res.json({
      resp: true,
      message: 'Get all trip schedule',
      trips: postdb[0][0],
      imagesdb,
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}

export const getDetailTripById = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()
    const {id} = req.params
    const postdb = await conn.query<RowDataPacket[]>(
      `CALL SP_GET_DETAIL_TRIP_ID(?,?);`,
      [id, req.idPerson]
    )

    const imagesdb = postdb[0][0].testing

    await conn.end()
    // console.log(postdb)
    console.log({
      resp: true,
      message: 'Get detail trips',
      trips: postdb[0][0],
      images: postdb[0][1],
      tripRecommends: postdb[0][2],
      tripMembers: postdb[0][3],
      imagesdb,
    })
    return res.json({
      resp: true,
      message: 'Get detail trips',
      trips: postdb[0][0],
      images: postdb[0][1],
      tripRecommends: postdb[0][2],
      tripMembers: postdb[0][3],
      imagesdb,
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}
export const deleteTripById = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()
    const { id } = req.params
    const deleteTrip = await conn.query<RowDataPacket[]>(
      `CALL SP_DELETE_TRIP_BY_ID(?);`,
      [id]
    )

    await conn.end()
   
    return res.json({
      resp: true,
      message: 'Delete trip success',
     
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}
export const getMemberTripById = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()
    const {id} = req.params
    const postdb = await conn.query<RowDataPacket[]>(
      `CALL SP_GET_MEMBERS_TRIP(?);`,
      [id]
    )

    const imagesdb = postdb[0][0].testing

    await conn.end()
    // console.log(postdb)
    console.log({
      resp: true,
      message: 'Get member trip',
      tripMembers: postdb[0][0],
      imagesdb,
    })
    return res.json({
      resp: true,
      message: 'Get members trip',
      tripMembers: postdb[0][0],
      imagesdb,
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}
export const getDetailExtraTripById = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()
    const {id} = req.params

    console.log(id,req.idPerson);
    
    const postdb = await conn.query<RowDataPacket[]>(
      `CALL SP_GET_DETAIL_TRIP_SCHEDULE(?,?);`,
      [id, req.idPerson]
    )
    
    const imagesdb = postdb[0][0].testing

    await conn.end()
    console.log(postdb)
    console.log({
      resp: true,
      message: 'Get detail trips',
      trips: postdb[0][0],
      images: postdb[0][1],
      tripRecommends: postdb[0][2],
      tripMembers: postdb[0][3],
      imagesdb,
    })
    return res.json({
      resp: true,
      message: 'Get detail trips',
      trips: postdb[0][0],
      images: postdb[0][1],
      tripRecommends: postdb[0][2],
      tripMembers: postdb[0][3],
      imagesdb,
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}

export const getTripByIdPerson = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const postdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_POST_BY_ID_PERSON(?);`, [ req.idPerson ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'Get Posts by IdPerson',
            post: postdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const saveAndUnSaveTripByUser = async (req: Request, res: Response): Promise<Response> => {

    try {

        const { trip_uid,type}: ISaveTrip = req.body;
        const conn = await connect();
        console.log(trip_uid, type);
        
        if(type === 'save') {
          await conn.query('INSERT INTO trip_save(uid, trip_uid, person_uid) VALUE (?,?,?)', [ uuidv4(), trip_uid, req.idPerson]);
        }
        if(type === 'unsave') {
          await conn.query('DELETE FROM trip_save WHERE trip_uid = ? AND person_uid = ?', [trip_uid, req.idPerson]);
        }
          
        conn.end();

        return res.json({
            resp: true,
            message: 'Trip saved'
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}
export const joinTripByUser = async (req: Request, res: Response): Promise<Response> => {

    try {

        const { trip_uid,type,date_start,date_end }: IJoinTrip = req.body;

        const conn = await connect();

        const checkMatch = await conn.query<RowDataPacket[]>(
          'CALL SP_CHECK_DUPLICATE_TRIP(?,?,?)',
          [req.idPerson, date_start, date_end]
        )
        console.log(checkMatch[0])
        console.log(checkMatch[0][0])
        console.log(checkMatch[0][1])
          if (
            checkMatch[0][0][0]?.countTripCreated !== 0 &&
            checkMatch[0][1][0]?.countTripJoined !== 0
          ) {
            return res.status(500).json({
              resp: false,
              message:
                'Lỗi đã trùng với chuyến đi đã tạo/ chuyến đi đã tham gia',
            })
          }
          if (checkMatch[0][0][0]?.countTripCreated !== 0) {
            return res.status(500).json({
              resp: false,
              message: 'Lỗi đã trùng với chuyến đi đã tạo',
            })
          }
          if (checkMatch[0][1][0]?.countTripJoined !== 0) {
            return res.status(500).json({
              resp: false,
              message: 'Lỗi đã trùng với chuyến đi đã tham gia',
            })
          } 
       

        // if (
        //   checkMatch[0][0]?.countTripCreated !== 0 &&
        //   checkMatch[0][1]?.countTripJoined
        // ) {
        //   conn.end()
        //   return res.status(500).json({
        //     resp: false,
        //     message: 'Lỗi đã trùng với chuyến đi khác.',
        //   })
        // } else {
          if (type === 'join') {
            await conn.query(
              'INSERT INTO trip_members(uid, trip_uid, person_uid) VALUE (?,?,?)',
              [uuidv4(), trip_uid, req.idPerson]
            )
          }

          if (type === 'cancel') {
            await conn.query(
              ' DELETE FROM trip_members WHERE trip_uid = ? AND person_uid = ?',
              [trip_uid, req.idPerson]
            )
          }
           conn.end()

           return res.json({
             resp: true,
             message: 'Joined Trip',
           })
        // }

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const addRateTrip = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { trip_uid, trip_comment, trip_rate, trip_member_uid }: ICommentTrip =
      req.body

    const conn = await connect()

    await conn.query(
      'UPDATE trip_members SET trip_comment = ?, trip_rate = ? WHERE uid = ? AND trip_uid = ? AND person_uid = ? ',
      [trip_comment,trip_rate,trip_member_uid ,trip_uid, req.idPerson]
    )

    conn.end()

    return res.json({
      resp: true,
      message: 'Joined Trip',
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}

export const addRoleForUserOfTrip = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { trip_uid, role, trip_member_uid }: IRoleTrip =
      req.body
      console.log(req.body);
      
    const conn = await connect()

    await conn.query(
      'UPDATE trip_members SET trip_role = ? WHERE uid = ?',
      [role,trip_member_uid]
    )

    conn.end()

    return res.json({
      resp: true,
      message: 'Added role Trip',
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}

export const updateStatusOfTrip = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const { trip_uid, status }: IStatusTrip = req.body
    console.log(req.body)

    const conn = await connect()

    await conn.query('UPDATE trips SET trip_status = ? WHERE uid = ?', [
      status,
      trip_uid,
    ])

    conn.end()

    return res.json({
      resp: true,
      message: 'Updated status Trip',
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}

export const getListSavedTripsByUser = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const listSavedPost = await conn.query<RowDataPacket[]>(`CALL SP_GET_LIST_POST_SAVED_BY_USER(?);`, [ req.idPerson ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'List Saved Post',
            listSavedPost: listSavedPost[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const getAllTripsForSearch = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const postsdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_ALL_POSTS_FOR_SEARCH(?);`, [ req.idPerson ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'Get All Post For Search',
            posts: postsdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const likeOrUnLikeTrip = async (req: Request, res: Response): Promise<Response> => {

    try {

        const { uidPost, uidPerson }: ILikePost = req.body;

        const conn = await connect();

        const isLikedb = await conn.query<RowDataPacket[]>('SELECT COUNT(uid_likes) AS uid_likes FROM likes WHERE user_uid = ? AND post_uid = ? LIMIT 1', [ req.idPerson, uidPost ]);

        if( isLikedb[0][0].uid_likes > 0 ){

            await conn.query('DELETE FROM likes WHERE user_uid = ? AND post_uid = ?', [ req.idPerson, uidPost ]);

            await conn.query('DELETE FROM notifications WHERE type_notification = 2 AND user_uid = ? AND post_uid = ?', [ uidPerson, uidPost ]);

            conn.end();

            return res.json({
                resp: true,
                message: 'unlike',
            });

        }

        await conn.query('INSERT INTO likes (uid_likes, user_uid, post_uid) VALUE (?,?,?)', [ uuidv4(), req.idPerson, uidPost ]);

        await conn.query('INSERT INTO notifications (uid_notification, type_notification, user_uid, followers_uid, post_uid) VALUE (?,?,?,?,?)', [uuidv4(), 2, uidPerson, req.idPerson, uidPost ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'like',
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const getCommentsByIdTrip = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const commentsdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_COMMNETS_BY_UIDPOST(?);`, [ req.params.uidPost]);

        conn.end();

        return res.json({
            resp: true,
            message: 'Get Commets',
            comments: commentsdb[0][0]
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const addNewComment = async (req: Request, res: Response): Promise<Response> => {

    try {

        const { uidPost, comment }: INewComment = req.body;

        const conn = await connect();

        await conn.query('INSERT INTO comments (uid, comment, person_uid, post_uid) VALUE (?,?,?,?)',[ uuidv4(), comment, req.idPerson,  uidPost ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'New comment'
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const likeOrUnLikeComment = async (req: Request, res: Response): Promise<Response> => {

    try {

        const { uidComment }: IUidComment = req.body;

        const conn = await connect();

        const isLikedb = await conn.query<RowDataPacket[]>('SELECT is_like FROM comments WHERE uid = ? LIMIT 1', [ uidComment ]);

        if( isLikedb[0][0].is_like > 0 ){

            await conn.query('UPDATE comments SET is_like = ? WHERE uid = ?', [ 0, uidComment ]);

            conn.end();

            return res.json({
                resp: true,
                message: 'unlike comment',
            });

        }

        await conn.query('UPDATE comments SET is_like = ? WHERE uid = ?', [ 1, uidComment ]);

        conn.end();

        return res.json({
            resp: true,
            message: 'like comment',
        });

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const getAllTripByUserID = async (req: Request, res: Response): Promise<Response> => {

    try {

        const conn = await connect();

        const tripsdb = await conn.query<RowDataPacket[]>(`CALL SP_GET_ALL_TRIP_BY_USER(?);`, [req.idPerson]);

        conn.end();


        console.log('Trip user: ',tripsdb[0][0])
        
        return res.json({
          resp: true,
          message: 'Trips By User ID',
          trips: tripsdb[0][0],
        })

    } catch(err) {
        return res.status(500).json({
            resp: false,
            message: err
        });
    }

}

export const InsertListChatTrip = async (uidSource: string, uidTarget: string) => {
  const conn = await connect()

  const verifyExistsSourceone = await conn.query<RowDataPacket[]>(
    'SELECT COUNT(uid_list_chat) AS chat FROM list_chats WHERE source_uid = ? AND target_uid = ? LIMIT 1',
    [uidSource, uidTarget]
  )

  if (verifyExistsSourceone[0][0].chat == 0) {
    await conn.query(
      'INSERT INTO list_chats (uid_list_chat, source_uid, target_uid) VALUE (?,?,?)',
      [uuidv4(), uidSource, uidTarget]
    )
  }

  conn.end()
}

export const updateLastMessageTrip = async (
  uidTarget: string,
  uidPerson: string,
  message: string
) => {
  const conn = await connect()

  const update = new Date().toISOString().slice(0, 19).replace('T', ' ')

  await conn.query(
    'UPDATE list_chats SET last_message = ?, updated_at = ? WHERE source_uid = ? AND target_uid = ?',
    [message, update, uidPerson, uidTarget]
  )

  conn.end()
}

export const addNewMessageTrip = async (
  uidSource: string,
  uidTargetTrip: string,
  message: string
) => {
  const conn = await connect()
  await conn.query(
    'INSERT INTO trip_messages (uid_message_trip, soure_uid, target_trip_uid, message) VALUE (?,?,?,?)',
    [uuidv4(), uidSource, uidTargetTrip, message]
  )

  conn.end()
}

export const getAllMessagesById = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()

    const messagesdb = await conn.query<RowDataPacket[]>(
      `CALL SP_ALL_MESSAGE_TRIP_BY_ID(?);`,
      [req.params.id]
    )

    conn.end()

    return res.json({
      resp: true,
      message: 'get all messages by trip id',
      listMessage: messagesdb[0][0],
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}

export const getLocationAllMemberTripById = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const conn = await connect()
    const { id } = req.params
    const result = await conn.query<RowDataPacket[]>(
      `CALL SP_GET_LOCATION_ALL_MEMBER_BY_TRIP_ID(?);`,
      [id]
    )
    
    const leader = result[0][0][0];
    const members = result[0][1] as IMemberLocation[];
    console.log(leader, members);
    
    const locationLeader : Location = {
      lat: leader?.lat,
      lng: leader?.lng
    } 

    const memembersTemp = members.map((member: IMemberLocation) => {
        const locationMember: Location = {
          lat: member?.lat ?? 0,
          lng: member?.lng ?? 0
        }
        const distance = haversine(locationLeader,locationMember);
        if(distance > 1.5) {
          return {
            ...member,
            type: 'danger',
            message: "Lạc nhóm",
          }
        }
        if(distance > 0.7 && distance <= 1.5) {
          return {
            ...member,
            type: 'warning',
            message: "Di chuyển xa nhóm",
          }
        }
        return {
          ...member,
          type: 'normal',
          message: 'An toàn'
        }
    })
    

    await conn.end()
    // console.log(postdb)
    console.log({
      resp: true,
      message: 'Get all location member trip',
      leader,
      memembersTemp,
    })
    return res.json({
      resp: true,
      message: 'Get all location member trip',
      leader,
      memembersTemp,
    })
  } catch (err) {
    return res.status(500).json({
      resp: false,
      message: err,
    })
  }
}