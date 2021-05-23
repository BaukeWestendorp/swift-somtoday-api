//
// Created by Bauke Westendorp on 18/05/2021.
//

// TODO make variables readonly

import Foundation

// MARK: General
public typealias LoginCallback = () -> LoginCredentials

public struct LoginCredentials {
	public init(organisation: Organisation, username: String, password: String) {
		self.organisation = organisation
		self.username = username
		self.password = password
	}

	public let organisation: Organisation
	public let username: String
	public let password: String
}

public struct Link: Codable {
	public let id: Int
	public let rel: String
	public let type: String
	public let href: String?
}

public struct Permission: Codable {
	public let full: String
	public let type: String
	public let operations: [String]
	public let instances: [String]
}

public protocol AdditionalObjects: Codable {

}

// MARK: Schooljaar

public struct Schooljaar: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
	public let vanafDatum: String
	public let totDatum: String
	public let isHuidig: Bool
}

// MARK: Account
public struct Account: Codable {
	public let links: [Link]
	public let permissions: [Permission]
	public let additionalObjects: AccountAdditionalObjects

	public let gebruikersnaam: String
	public let accountPermissions: [Permission] // FIXME Should this be [Permission]??
	public let persoon: Persoon
}

public struct AccountAdditionalObjects: AdditionalObjects {
	public let restricties: Restricties?
}

public struct Restricties: Codable {
	public let items: [EloRestricties]
}

public struct EloRestricties: Codable {
	public let links: [Link]
	public let permissions: [Permission]
	public let vestigingsId: Int
	public let mobieleAppAan: Bool
	public let studiewijzerAan: Bool
	public let berichtenVerzendenAan: Bool
	public let leermiddelenAan: Bool
	public let adviezenTokenAan: Bool
	public let opmerkingRapportCijferTonenAan: Bool
	public let periodeGemiddeldeTonenResultaatAan: Bool
	public let rapportGemiddeldeTonenResultaatAan: Bool
	public let rapportCijferTonenResultaatAan: Bool
	public let toetssoortgemiddeldenAan: Bool
	public let seResultaatAan: Bool
	public let stamgroepLeerjaarAan: Bool
	public let emailWijzigenAan: Bool
	public let mobielWijzigenAan: Bool
	public let wachtwoordWijzigenAan: Bool
	public let absentiesBekijkenAan: Bool
	public let absentieConstateringBekijkenAan: Bool
	public let absentieMaatregelBekijkenAan: Bool
	public let absentieMeldingBekijkenAan: Bool
	public let berichtenBekijkenAan: Bool
	public let cijfersBekijkenAan: Bool
	public let huiswerkBekijkenAan: Bool
	public let nieuwsBekijkenAan: Bool
	public let pasfotoLeerlingTonenAan: Bool
	public let pasfotoMedewerkerTonenAan: Bool
	public let profielBekijkenAan: Bool
	public let roosterBekijkenAan: Bool
	public let vakkenBekijkenAan: Bool
	public let lesurenVerbergenSettingAan: Bool
}

public struct Persoon: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let UUID: String
	public let leerlingnummer: Int
	public let roepnaam: String
	public let achternaam: String
}

// MARK: Pupil
public struct Pupils: Codable {
	public let items: [Pupil]
}

public struct Pupil: Codable {
	public let links: [Link]
	public let permissions: [Permission]
	public let additionalObjects: PupilAdditionalData

	public let UUID: String
	public let leerlingnummer: Int
	public let roepnaam: String
	public let achternaam: String
	public let email: String
	public let mobielNummer: String
	public let geboortedatum: String
	public let geslacht: String
}

public struct PupilAdditionalData: Codable {
	public let huidigeLichting: Lichting
	public let rVestiging: Vestiging
	public let lestijden: Lestijden
}

public struct Lichting: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
	public let lichtingSchooljaren: [LichtingSchooljaar]
	public let onderwijssoort: OnderwijsSoort
}

public struct OnderwijsSoort: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let afkorting: String
	public let isOnderbouw: Bool
}

public struct LichtingSchooljaar: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let schooljaar: Schooljaar
	public let leerjaar: Int
	public let heeftExamendossier: Bool
}

public struct Vestiging: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
}

public struct Lestijden: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let vestiging: Vestiging
	public let actief: Bool
	public let lesuren: [Lesuur]
}

public struct Lesuur: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let nummer: Int
	public let begintijd: String
	public let eindtijd: String
}

// MARK: Medewerkers

public struct Medewerkers: Codable {
	public let items: [Medewerker]
}

public struct Medewerker: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let UUID: String
	public let nummer: Int
	public let afkorting: String
	public let achternaam: String
	public let geslacht: String
	public let voorletters: String
	public let voorvoegsel: String?
	public let roepnaam: String
}

// MARK: Afspraken

public struct Afspraken: Codable {
	public let items: [Afspraak]
}

public struct Afspraak: Codable {
	public let links: [Link]
	public let permissions: [Permission]
	public let additionalObjects: AfspraakAdditionalObjects

	public let afspraakType: AfspraakType
	public let beginDatumTijdRaw: String
	public let eindDatumTijdRaw: String
	public let titel: String
	public let omschrijving: String
	public let presentieRegistratieVerplicht: Bool
	public let presentieRegistratieVerwerkt: Bool
	public let afspraakStatus: String
	public let vestiging: Vestiging

	// These are optional because you can have a 'lesson' for information about a day. e.g. "Schooltrip"
	public let locatie: String?
	public let beginLesuur: Int?
	public let eindLesuur: Int?

	//	public let bijlagen: [] // TODO Unknown Type
	
	public var beginDatumTijd: Date? {
		Util.fromDatumTijd(beginDatumTijdRaw)
	}

	public var eindDatumTijd: Date? {
		Util.fromDatumTijd(eindDatumTijdRaw)
	}
}

public extension Afspraak {
	enum CodingKeys: String, CodingKey {
		case links
		case permissions
		case additionalObjects
		case afspraakType
		case beginDatumTijdRaw = "beginDatumTijd"
		case eindDatumTijdRaw = "eindDatumTijd"
		case titel
		case omschrijving
		case presentieRegistratieVerplicht
		case presentieRegistratieVerwerkt
		case afspraakStatus
		case vestiging
		case locatie
		case beginLesuur
		case eindLesuur
		// TODO Do these need to be included???
	}
}

public struct AfspraakAdditionalObjects: Codable {
	public let vak: Vak?
	public let docentAfkortingen: String?
	public let leerlingen: LeerlingPrimers?
	//	public let onlineDeelnames: []?
}

public struct LeerlingPrimers: Codable {
	public let items: [LeerlingPrimer]
}

public struct LeerlingPrimer: Codable {
	public let links: [Link]
	public let permissions: [Permission]
	public let UUID: String
	public let leerlingnummer: Int
	public let roepnaam: String
	public let achternaam: String
}

public struct Vak: Codable {
	public let links: [Link]
	public let permissions: [Permission]
	public let afkorting: String
	public let naam: String
}

public struct AfspraakType: Codable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
	public let omschrijving: String
	public let standaardKleur: Int
	public let categorie: String
	public let activiteit: String
	public let percentageIIVO: Int
	public let presentieRegistratieDefault: Bool
	public let actief: Bool
	public let vestiging: Vestiging
}

// MARK: Authentication

public struct AuthToken: Codable {
	public let access_token: String
	public let refresh_token: String
	public let somtoday_api_url: String
	public let scope: String
	public let somtoday_tenant: String
	public let id_token: String
	public let token_type: String
	public let expires_in: Int
}

// MARK: Organisations

public struct Organisations: Codable {
	public let instellingen: [Organisation]
}

public struct Organisation: Codable {
	public let uuid: String
	public let naam: String
	public let plaats: String
	public let oidcurls: [OIDCUrl]

	public init(uuid: String, naam: String, plaats: String, oidcurls: [OIDCUrl]) {
		self.uuid = uuid
		self.naam = naam
		self.plaats = plaats
		self.oidcurls = oidcurls
	}
}

public struct OIDCUrl: Codable {
	public let omschrijving: String
	public let url: String
	public let domain_hint: String

	public init(omschrijving: String, url: String, domain_hint: String) {
		self.omschrijving = omschrijving
		self.url = url
		self.domain_hint = domain_hint
	}
}