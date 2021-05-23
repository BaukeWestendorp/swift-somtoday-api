import Alamofire
import Foundation

public class SomtodayAPI {
	private static var currentAuthToken: AuthToken? = nil
	private static var loginCallback: LoginCallback? = nil

	public static func getOrganisations(complete: @escaping (Result<Organisations, SomtodayError>) -> Void) {
		AF.request("https://servers.somtoday.nl/organisaties.json")
		  .responseDecodable(of: [Organisations].self) { response in
			  switch response.result {
				  case .success(let organisations):
					  complete(.success(organisations[0]))
				  case .failure(_):
					  complete(.failure(SomtodayError(
						  failureReason: .failedResponse,
						  failureDescription: "Failed to get Organisaties"
					  )))
			  }
		  }
	}

	public class func setLoginCallback(callback: @escaping LoginCallback) {
		loginCallback = callback
	}

	public static func authenticate(credentials: LoginCredentials, complete: @escaping (Result<AuthToken, SomtodayError>) -> Void) {
		let params = [
			"grant_type": "password",
			"username": "\(credentials.organisation.uuid)\\\(credentials.username)",
			"password": credentials.password,
			"scope": "openid",
			"client_id": "D50E0C06-32D1-4B41-A137-A9A850C892C2",
		]

		AF.request("https://somtoday.nl/oauth2/token",
		           method: .post,
		           parameters: params
		  )
		  .responseDecodable(of: AuthToken.self) { response in
			  switch response.result {
				  case .success(let token):
					  complete(.success(token))
				  case .failure(_):
					  complete(.failure(SomtodayError(
						  failureReason: .failedResponse,
						  failureDescription: "Failed to get AuthToken"
					  )))
			  }
		  }
	}

	public static func authenticate(refreshToken: String, complete: @escaping (Result<AuthToken, SomtodayError>) -> Void) {
		let params = [
			"grant_type": "refresh_token",
			"refresh_token": refreshToken,
			"client_id": "D50E0C06-32D1-4B41-A137-A9A850C892C2",
		]

		AF.request("https://somtoday.nl/oauth2/token",
		           method: .post,
		           parameters: params
		  )
		  .responseDecodable(of: AuthToken.self) { [self] response in
			  switch response.result {
				  case .success(let token):
					  currentAuthToken = token
					  complete(.success(token))
				  case .failure(let error):
					  complete(.failure(SomtodayError(
						  failureReason: .failedResponse,
						  failureDescription: "Failed to get AuthToken"
					  )))
					  print("ERROR (Failed to get AuthToken): \(error)")
					  currentAuthToken = nil
			  }
		  }
	}

	public static func getSchooljaar(complete: @escaping (Result<Schooljaar, SomtodayError>) -> Void) {
		makeRequest(path: "/rest/v1/schooljaren/huidig", of: Schooljaar.self) { result in
			switch result {
				case .success(let schooljaar):
					complete(.success(schooljaar))
				case .failure(let error):
					complete(.failure(error))
			}
		}
	}

	public enum AccountAdditionals: String {
		case restricties
	}

	public static func getAccount(additionals: [AccountAdditionals], complete: @escaping (Result<Account, SomtodayError>) -> Void) {
		makeRequest(path: "/rest/v1/account/me",
		            of: Account.self,
		            additionals: additionals.map {
			            $0.rawValue
		            }
		) { result in
			switch result {
				case .success(let account):
					complete(.success(account))
				case .failure(let error):
					complete(.failure(error))
			}
		}
	}

	public enum LeerlingenAdditionals: String {
		case lestijden
		case rVestiging
		case huidigeLichting
	}

	public static func getLeerlingen(additionals: [LeerlingenAdditionals], complete: @escaping (Result<Pupils, SomtodayError>) -> Void) {
		// TODO Get from ID (/[id])
		// TODO Range
		makeRequest(path: "/rest/v1/leerlingen",
		            of: Pupils.self,
		            additionals: additionals.map {
			            $0.rawValue
		            }
		) { result in
			switch result {
				case .success(let pupils):
					complete(.success(pupils))
				case .failure(let error):
					complete(.failure(error))
			}
		}
	}

	public static func getMedewerkers(complete: @escaping (Result<Medewerkers, SomtodayError>) -> Void) {
		// TODO Range
		makeRequest(path: "/rest/v1/medewerkers/ontvangers",
		            of: Medewerkers.self
		) { result in
			switch result {
				case .success(let medewerkers):
					complete(.success(medewerkers))
				case .failure(let error):
					complete(.failure(error))
			}
		}
	}

	public enum AfsprakenAdditionals: String {
		case vak
		case docentAfkortingen
		case leerlingen
//		case onlineDeelnames TODO Unknown Data
	}

	public static func getAfspraken(additionals: [AfsprakenAdditionals], dateInterval: DateInterval, complete: @escaping (Result<Afspraken, SomtodayError>) -> Void) {
		// TODO Range
		// TODO leerling query parameter
		makeRequest(path: "/rest/v1/afspraken",
		            of: Afspraken.self,
		            additionals: additionals.map {
			            $0.rawValue
		            },
		            parameters: [
			            "begindatum": dateInterval.start.toSimpleString(),
			            "einddatum": dateInterval.end.toSimpleString(),
			            "sort": "asc-id",
		            ]
		) { result in
			switch result {
				case .success(let afspraken):
					complete(.success(afspraken))
				case .failure(let error):
					complete(.failure(error))
			}
		}
	}

	private static func makeRequest<Response: Decodable>(path: String, of: Response.Type, additionals: [String]? = nil, headers: HTTPHeaders? = nil, parameters: Parameters? = nil, complete: @escaping (Result<Response, SomtodayError>) -> Void) {
		makeAuthenticatedRequest { [self] in
			if let currentAuthToken = currentAuthToken {
				var allHeaders: HTTPHeaders = [
					"Authorization": "\(currentAuthToken.token_type) \(currentAuthToken.access_token)",
					"Accept": "application/json"
				]
				if let headers = headers {
					for header in headers {
						allHeaders.add(header)
					}
				}

				var params = parameters
				if additionals != nil {
					let addi = ["additional": additionals!]
					if params == nil {
						params = addi
					} else {
						params!.merge(addi, uniquingKeysWith: { (current, _) in
							current
						})
					}
				}

				// TODO Concat path safely
				AF.request(currentAuthToken.somtoday_api_url + path,
				           parameters: params,
				           headers: allHeaders
				  )
				  .responseDecodable(of: Response.self) { response in
					  switch response.result {
						  case .success(let value):
							  complete(.success(value))
						  case .failure(_):
							  complete(.failure(SomtodayError(
								  failureReason: .failedResponse,
								  failureDescription: "Failed to get \(Response.self)"
							  )))
							  print("Response: \n" + response.debugDescription)
					  }
				  }
			} else {
				complete(.failure(SomtodayError(
					failureReason: .invalidAuthToken,
					failureDescription: "Current AuthToken is invalid"
				)))
			}
		}
	}

	private static func makeAuthenticatedRequest(complete: @escaping () -> Void) {
		guard let login = loginCallback else {
			fatalError("No loginCallback was found! Use setLoginCallback() before trying to authenticate!")
		}

		if currentAuthToken == nil {
			let credentials = login()
			authenticate(credentials: credentials) { [self] result in
				switch result {
					case .success(let token):
						currentAuthToken = token


					case .failure(let error):
						currentAuthToken = nil
						print("ERROR (Failed to get AuthToken): \(error) | Retrying...")
						makeAuthenticatedRequest {
						}
				}

				complete()
			}
		} else {
			complete()
		}
	}
}

private extension Date {
	func toSimpleString() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"

		return formatter.string(from: self)
	}
}
