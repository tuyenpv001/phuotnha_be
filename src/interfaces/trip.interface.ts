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