//
// Created by Bauke Westendorp on 23/05/2021.
//

import Foundation

struct Util {
	static func fromDatumTijd(_ datumTijd: String) -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

		return formatter.date(from: datumTijd)
	}
}
