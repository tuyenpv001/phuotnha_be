
export interface INewPost {
  description: string
  user_uid: string
  type_privacy: string
}

export interface ISavePost {
    post_uid: string
    type: 'save' | 'unsave'
}
export interface IUnSavePost {
  post_save_ui: string
}

export interface ILikePost {
    uidPost: string,
    uidPerson: string
}

export interface INewComment {
    uidPost: string,
    comment: string
}

export interface IUidComment {
    uidComment: string
}