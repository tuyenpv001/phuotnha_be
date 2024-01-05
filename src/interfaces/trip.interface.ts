export interface INewTrip {
 user_uid?: string
 trip_title: string
 trip_description: string
 trip_date_start: string
 trip_date_end: string
 trip_from: string
 trip_to: string
 trip_member: number
 trip_status: "open" | 'cancel' | 'pending' | 'completed'
 trip_schedule?: TripSchedule[]

}

// INSERT INTO `trip_schedule`(`uid`, `trip_uid`, `lat`, `lng`, `address_short`, `address_detail`, `isGasStation`, `isRepairMotobike`) VALUES ('[value-1]','[value-2]','[value-3]','[value-4]','[value-5]','[value-6]','[value-7]','[value-8]')
export interface TripSchedule {
  uid: string
  trip_uid: string
  lat: number
  lng: number
  address_short: string
  address_detail: string
  isGasStation: boolean
  isRepairMotobike: boolean
}

export interface IMemberTrip {
  trip_uid: string
  person_uid: string
  trip_role: 'member' | 'pho_nhom' | 'thu_quy'
  trip_rate?: number
  trip_comment?: string
}
export interface ISaveTrip {
  trip_uid: string
  type: 'save' | 'unsave'
}
export interface IRecommendTrip {
 trip_uid: string
 trip_point: string
 trip_des_point: string
}

export interface IJoinTrip {
 trip_uid: string
 type: 'cancel' | 'join'
 date_start?: Date
 date_end?: Date
}
export interface ICommentTrip {
  trip_member_uid: string
  trip_uid: string
  trip_rate: number
  trip_comment: string
}
export interface IRoleTrip {
  role: 'member' | 'pho_nhom' | 'thu_quy'
  trip_uid: string
  trip_member_uid:  string
}


export interface IStatusTrip {
  status: 'open' |'block'|'cancel'| 'pending'|'is_beginning'|'completed' | 'reopen'
  trip_uid: string
}

export interface IMemberLocation {
  lat: number | null,
  lng: number | null,
  image: string | null,
  fullname: string | null,
  isMember: number
}



export const mockData = [
  {
    lat: -30.0722165,
    lng: -51.0969571,
    image: 'avatar-default.png',
    fullname: 'Văn Hào',
    isMember: 1,
    type: 'warning',
    message: 'Di chuyển quá xa đoàn',
    level: 2
  },
  {
    lat:63.0709556,
    lng:21.6602532,
    image:"avatar-default.png",
    fullname:"Nguyễn Tý",
    isMember:1,
    type:'info',
    level: 1,
    message: "An toàn"
  },
  {
    lat:49.0525513,
    lng:17.5271323,
    image:"avatar-default.png",
    fullname:"Tuấn Đạt",
    isMember:1,
    level: 0,
    type:'off',
    message:"offline"
  },
  {
    lat:-30.0722165,
    lng:-51.0969571,
    image:"avatar-default.png",
    fullname:"Văn Tuyển",
    isMember:1,
    type:'danger',
    level: 3,
    message:"Khẩn cấp"
  },
]

/** Level
 * 0: off
 * 1: info
 * 2: warning
 * 3: danger
 */