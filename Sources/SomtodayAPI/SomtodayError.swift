//
// Created by Bauke Westendorp on 19/05/2021.
//

import Foundation

public struct SomtodayError: Error {
	public let failureReason: FailureReason
	public let failureDescription: String

	public enum FailureReason {
		case failedResponse
		case invalidAuthToken
	}
}