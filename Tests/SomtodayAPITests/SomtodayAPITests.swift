import XCTest
import Alamofire
@testable import SomtodayAPI

final class SomtodayAPITests: XCTestCase {
	func fakeLoginCallback() -> LoginCredentials {
		LoginCredentials(organisation: Credentials.organisation, username: Credentials.username, password: Credentials.password)
	}

	func testGetOrganisations() {
		let expectation = self.expectation(description: "Getting Organisations")
		var liudger: Organisation?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getOrganisations { result in
			switch result {
				case .success(let orgs):
					let filtered = orgs.instellingen.filter({
						$0.naam == "CSG Liudger"
					});
					if filtered.count > 0 {
						liudger = filtered[0]
					} else {
						print("ERROR: Failed to find 'CSG Liudger'")
					}
				case .failure(let error):
					print("ERROR: \(error)")
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 5)

		XCTAssertNotNil(liudger)
	}

	func testAuthenticationCredentials() {
		let expectation = self.expectation(description: "Authenticating")
		var authToken: AuthToken?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getOrganisations { [self] orgResult in
			switch orgResult {
				case .success(_):
					SomtodayAPI.authenticate(credentials: fakeLoginCallback()) { tokenResult in
						switch tokenResult {
							case .success(let token):
								authToken = token
							case .failure(let error):
								print("ERROR: \(error)")
						}

						expectation.fulfill()
					}
				case .failure(let error):
					print("ERROR: \(error)")
			}
		}

		waitForExpectations(timeout: 5)

		XCTAssertNotNil(authToken)
	}

	func testAuthenticationRefreshToken() {
		let expectation = self.expectation(description: "Authenticating")
		var authToken: AuthToken?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getOrganisations { [self] orgResult in
			switch orgResult {
				case .success(_):
					SomtodayAPI.authenticate(credentials: fakeLoginCallback()) { authResult in
						switch authResult {
							case .success(let token):
								SomtodayAPI.authenticate(refreshToken: token.refresh_token) { tokenResult in
									switch tokenResult {
										case .success(let token):
											authToken = token
										case .failure(let error):
											print("ERROR: \(error)")
									}

									expectation.fulfill()
								}

							case .failure(let error):
								print("Error: \(error)")
						}
					}
				case .failure(let error):
					print("ERROR: \(error)")
			}
		}

		waitForExpectations(timeout: 5)

		XCTAssertNotNil(authToken)
	}

	func testGetSchooljaar() {
		let expectation = expectation(description: "Getting Schooljaar")
		var schooljaar: Schooljaar?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getSchooljaar { result in
			switch result {
				case .success(let value):
					schooljaar = value
				case .failure(let error):
					print("ERROR: \(error)")
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 5)

		XCTAssertNotNil(schooljaar)
	}

	func testGetLeerlingen() throws {
		let expectation = expectation(description: "Getting Leerlingen")
		var pupils: Pupils?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getLeerlingen(additionals: [.huidigeLichting, .lestijden, .rVestiging]) { result in
			switch result {
				case .success(let value):
					pupils = value
				case .failure(let error):
					print("ERROR: \(error)")
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 5)

		let unwrapped = try XCTUnwrap(pupils)
		XCTAssertNotNil(unwrapped.items[0].additionalObjects.rVestiging)
		XCTAssertNotNil(unwrapped.items[0].additionalObjects.lestijden)
		XCTAssertNotNil(unwrapped.items[0].additionalObjects.huidigeLichting)
	}

	func testGetAccount() throws {
		let expectation = expectation(description: "Getting Account")
		var account: Account?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getAccount(additionals: [.restricties]) { result in
			switch result {
				case .success(let value):
					account = value
				case .failure(let error):
					print("ERROR: \(error)")
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 5)

		let unwrapped = try XCTUnwrap(account)
		XCTAssertNotNil(unwrapped.additionalObjects.restricties)
	}

	func testGetMedewerkers() {
		let expectation = expectation(description: "Getting Medewerkers")
		var medewerkers: Medewerkers?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		SomtodayAPI.getMedewerkers { result in
			switch result {
				case .success(let value):
					medewerkers = value
				case .failure(let error):
					print("ERROR: \(error)")
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 5)

		XCTAssertNotNil(medewerkers)
	}

	func testGetAfspraken() throws {
		let expectation = expectation(description: "Getting Afspraken")
		var afspraken: Afspraken?
		SomtodayAPI.setLoginCallback(callback: fakeLoginCallback)

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"

		let dateInterval = DateInterval(
			start: dateFormatter.date(from: "2021-02-01") ?? Date(),
			end: dateFormatter.date(from: "2021-02-02") ?? Date()
			)
		XCTAssertFalse(dateInterval.duration.isZero)

		SomtodayAPI.getAfspraken(additionals: [.docentAfkortingen, .vak, .leerlingen], dateInterval: dateInterval) { result in
			switch result {
				case .success(let value):
					afspraken = value
				case .failure(let error):
					print("ERROR: \(error)")
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 5)

		let unwrapped = try XCTUnwrap(afspraken)
		XCTAssertNotEqual(unwrapped.items.count, 0);
		XCTAssertNotNil(unwrapped.items[0].additionalObjects.leerlingen)
//		XCTAssertNotNil(unwrapped.items[0].additionalObjects.vak) // TODO Why is vak always null?
		XCTAssertNotNil(unwrapped.items[0].additionalObjects.docentAfkortingen)
	}
}
