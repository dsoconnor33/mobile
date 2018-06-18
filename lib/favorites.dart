import 'package:firebase_auth/firebase_auth.dart';

import 'user.dart';

class Favorites {
  static updateCandidate(Map favs, Map favIdMap, Map candidate) {
    final favId = candidate['favId'];
    if (favIdMap.containsKey(favId) && favId != favIdMap[favId]) {
      _updateFav(favs, candidate, favIdMap, favIdMap[favId]);
    } else {
      candidate['fav'] = _isFav(favs, candidate['favId']);
    }
  }

  static void setCandidateFavorite(
      Map favs, FirebaseUser firebaseUser, Map candidate) {
    if (candidate.containsKey('oldFavId')) {
      favs.remove(candidate['oldFavId']);
    }

    final favId = candidate['favId'];
    if (candidate['fav']) {
      favs.remove(favId);
    } else {
      favs[favId] = {'fav': true};
    }

    User.getFavCandidatesRef(firebaseUser).setData(favs);
  }

  static bool _isFav(Map favs, String favId) {
    if (favId == null) {
      return false;
    }
    Map favData = favs[favId];
    return favData == null ? false : favData['fav'] ?? false;
  }

  static void _updateFav(
      Map favs, Map candidate, favIdMap, String canonicalFavId) {
    if (candidate == null || favIdMap == null || canonicalFavId == null) {
      return;
    }
    if (candidate.containsKey('fav')) {
      return;
    }
    favIdMap.forEach((key, value) {
      if (value == canonicalFavId) {
        bool oldFav = _isFav(favs, key);
        bool fav = _isFav(favs, canonicalFavId);

        candidate['fav'] = oldFav || fav;
        candidate['favId'] = canonicalFavId;
        if (oldFav) {
          candidate['oldFavId'] = key;
        }
        return;
      }
    });
  }
}