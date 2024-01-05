export interface Location {
 lat: number
 lng: number 
}
type Unit = 'm' | 'km'

export function haversine(location1: Location, location2 : Location, unit = 'm') {
  var p = 0.017453292519943295 // Math.PI / 180
  var c = Math.cos
  var a =
    0.5 -
    c((location2.lat - location1.lat) * p) / 2 +
    (c(location1.lat * p) * c(location2.lat * p) * (1 - c((location2.lng - location1.lng) * p))) / 2


    const result = 12742 * Math.asin(Math.sqrt(a)); // 2 * R; R = 6371 km

  return unit === 'km' ? result : result * 1000; // Chuyển đơn vị nếu cần

  // return 12742 * Math.asin(Math.sqrt(a)) // 2 * R; R = 6371 km
}
