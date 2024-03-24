export interface Location {
 lat: number
 lng: number 
}
type Unit = 'm' | 'km'

// export function haversine(location1: Location, location2 : Location, unit = 'm') {
//   var p = 0.017453292519943295 // Math.PI / 180
//   var c = Math.cos
//   var a =
//     0.5 -
//     c((location2.lat - location1.lat) * p) / 2 +
//     (c(location1.lat * p) * c(location2.lat * p) * (1 - c((location2.lng - location1.lng) * p))) / 2


//     const result = 12742 * Math.asin(Math.sqrt(a)); // 2 * R; R = 6371 km

//   return unit === 'km' ? result : result * 1000; // Chuyển đơn vị nếu cần

//   // return 12742 * Math.asin(Math.sqrt(a)) // 2 * R; R = 6371 km
// }
function degreesToRadians(degrees : number) {
  return degrees * (Math.PI / 180)
}

export function haversine(location1: Location, location2: Location) {
  const R = 6371 // Bán kính trung bình của Trái Đất (đơn vị: km)

  const dLat = degreesToRadians(location2.lat - location1.lat)
  const dLon = degreesToRadians(location2.lng - location1.lng)

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(degreesToRadians(location1.lat)) *
      Math.cos(degreesToRadians(location2.lng)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  const distance = R * c

  return distance
}


export function calculateDistances(data : any[]) {
  const distances = []

  for (let i = 0; i < data.length; i++) {
    for (let j = i + 1; j < data.length; j++) {
      const distance = haversine(
        {
         lat: data[i].lat,
         lng: data[i].lng
        },
        {
          lat: data[j].lat,
          lng: data[j].lng
        }
      )

      distances.push({
        uid: data[i].uid,
        trip_uid: data[i].trip_uid,
        userId: data[i].user_id,
        from: data[i].fullname,
        userIdTo: data[j].user_id,
        to: data[j].fullname,
        lat: data[i].lat,
        lng: data[i].lng,
        index: data[i].index - data[j].index,
        is_mark: data[i].is_mark,
        distance: distance, // Round to 2 decimal places
      })
    }
  }

  return distances
}

export function calculateOneToMoreDistances(point: any ,data: any[]) {
  const distances = []

  for (let i = 0; i < data.length; i++) {
      const distance = haversine(
        {
          lat: data[i].lat,
          lng: data[i].lng,
        },
        {
         lat: point.lat,
         lng: point.lng
        }
      )

      distances.push({
        trip_uid: point.trip_uid,
        userId: point.user_id,
        from: point.fullname,
        to:  data[i].address_short,
        type: convertListType([
          {
          type: 'isGasStation',
          value:  data[i].isGasStation
          },
          {
          type: 'isRepairMotobike',
          value:  data[i].isRepairMotobike
          },
          {
          type: 'isEatPlace',
          value:  data[i].isEatPlace
          },
          {
          type: 'isCheckIn',
          value:  data[i].isCheckIn
          },
      ]),
        distance: distance, // Round to 2 decimal places
      })
  }

  return distances
}


// isGasStation: 1,
//     isRepairMotobike: 0,
//     isEatPlace: 0,
//     isCheckIn: 0

type TypeMarker  = {
  type: string,
  value: number
}

function convertType(type: TypeMarker ) {
  if(type.value) return type.type
}

function convertListType (list: TypeMarker[]){
  return list.filter(item => item.value !== 0)[0];
}
