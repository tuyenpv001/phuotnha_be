export interface Location {
 lat: number
 lng: number 
}

export function haversine(location1: Location, location2 : Location) {
  var p = 0.017453292519943295 // Math.PI / 180
  var c = Math.cos
  var a =
    0.5 -
    c((location2.lat - location1.lat) * p) / 2 +
    (c(location1.lat * p) * c(location2.lat * p) * (1 - c((location2.lng - location1.lng) * p))) / 2

  return 12742 * Math.asin(Math.sqrt(a)) // 2 * R; R = 6371 km
}
