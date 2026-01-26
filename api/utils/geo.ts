/**
 * Geografische Hilfsfunktionen
 */

/**
 * Berechnet die Distanz zwischen zwei Koordinaten in Kilometern (Haversine-Formel)
 */
export function haversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Erdradius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Konvertiert Grad zu Radiant
 */
function toRad(deg: number): number {
  return deg * (Math.PI / 180);
}

/**
 * Prüft ob ein Punkt innerhalb einer Bounding Box liegt
 */
export function isInBounds(
  lat: number,
  lng: number,
  bounds: {north: number; south: number; east: number; west: number}
): boolean {
  return (
    lat >= bounds.south &&
    lat <= bounds.north &&
    lng >= bounds.west &&
    lng <= bounds.east
  );
}

/**
 * MSH Region Bounding Box
 */
export const MSH_BOUNDS = {
  north: 51.75,
  south: 51.25,
  west: 10.75,
  east: 11.85,
};

/**
 * Erweiterte Bounding Box (+20km)
 */
export const MSH_EXTENDED_BOUNDS = {
  north: 51.93,
  south: 51.07,
  west: 10.5,
  east: 12.1,
};
