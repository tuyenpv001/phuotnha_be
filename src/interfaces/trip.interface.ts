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
  trip_member_uid?: string
  trip_uid: string
  trip_rate?: number
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
  type?: string,
  message?:  string,
  level?: number
  uid?:number,
  user_id?: string,
  index:number,
  is_mark: string
}

// {
//   uid: 1,
//   trip_uid: '349a5c74-e31b-4cb3-87aa-e3be559fa824',
//   user_id: 'e3be559fa8240',
//   fullname: 'Văn Hào',
//   avatar: 'avatar-default.png',
//   lat: 10.93931,
//   lng: 106.86912,
//   index: 0,
//   is_mark: 'no'
// }
// [ 10.93931, 106.86912 ], [ 10.93972, 106.8688 ],  [ 10.93995, 106.8686 ],
//     [ 10.93999, 106.86858 ], [ 10.94002, 106.86855 ], [ 10.94005, 106.86852 ],

export const mockData = [
  {
    lat: 10.93931,
    lng: 106.86912,
    image: 'avatar-default.png',
    fullname: 'Văn Hào',
    isMember: 1,
    type: 'warning',
    message: 'Di chuyển quá xa đoàn',
    level: 2,
  },
  {
    lat: 10.93972,
    lng: 106.8688,
    image: 'avatar-default.png',
    fullname: 'Nguyễn Tý',
    isMember: 1,
    type: 'info',
    level: 1,
    message: 'An toàn',
  },
  {
    lat: 10.93995,
    lng: 106.8686,
    image: 'avatar-default.png',
    fullname: 'Tuấn Đạt',
    isMember: 1,
    level: 0,
    type: 'off',
    message: 'offline',
  },
  {
    lat: 10.93999,
    lng: 106.86858,
    image: 'avatar-default.png',
    fullname: 'Văn Tuyển',
    isMember: 1,
    type: 'danger',
    level: 3,
    message: 'Khẩn cấp',
  },
]

/** Level
 * 0: off
 * 1: info
 * 2: warning
 * 3: danger
 */