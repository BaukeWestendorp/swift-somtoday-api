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

public struct Link: Decodable {
	public let id: Int
	public let rel: String
	public let type: String
	public let href: String?
}

public struct Permission: Decodable {
	public let full: String
	public let type: String
	public let operations: [String]
	public let instances: [String]
}

public protocol AdditionalObjects: Decodable {

}

// MARK: Schooljaar

public struct Schooljaar: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
	public let vanafDatum: String
	public let totDatum: String
	public let isHuidig: Bool
}

// MARK: Account
public struct Account: Decodable {
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

public struct Restricties: Decodable {
	public let items: [EloRestricties]
}

public struct EloRestricties: Decodable {
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

public struct Persoon: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let UUID: String
	public let leerlingnummer: Int
	public let roepnaam: String
	public let achternaam: String
}

// MARK: Pupil
public struct Pupils: Decodable {
	public let items: [Pupil]
}

public struct Pupil: Decodable {
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

public struct PupilAdditionalData: Decodable {
	public let huidigeLichting: Lichting
	public let rVestiging: Vestiging
	public let lestijden: Lestijden
}

public struct Lichting: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
	public let lichtingSchooljaren: [LichtingSchooljaar]
	public let onderwijssoort: OnderwijsSoort
}

public struct OnderwijsSoort: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let afkorting: String
	public let isOnderbouw: Bool
}

public struct LichtingSchooljaar: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let schooljaar: Schooljaar
	public let leerjaar: Int
	public let heeftExamendossier: Bool
}

public struct Vestiging: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let naam: String
}

public struct Lestijden: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let vestiging: Vestiging
	public let actief: Bool
	public let lesuren: [Lesuur]
}

public struct Lesuur: Decodable {
	public let links: [Link]
	public let permissions: [Permission]

	public let nummer: Int
	public let begintijd: String
	public let eindtijd: String
}

// MARK: Medewerkers

public struct Medewerkers: Decodable {
	public let items: [Medewerker]
}

public struct Medewerker: Decodable {
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

public struct Afspraken: Decodable {
	public let items: [Afspraak]
}

public struct Afspraak: Decodable {
	public let links: [Link]
	public let permissions: [Permission]
	public let additionalObjects: AfspraakAdditionalObjects

	public let afspraakType: AfspraakType
	public let beginDatumTijd: String
	public let eindDatumTijd: String
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
}

public struct AfspraakAdditionalObjects: Decodable {
	public let vak: Vak?
	public let docentAfkortingen: String?
	public let leerlingen: LeerlingPrimers?
	//	public let onlineDeelnames: []?
}

public struct LeerlingPrimers: Decodable {
	public let items: [LeerlingPrimer]
}

public struct LeerlingPrimer: Decodable {
	public let links: [Link]
	public let permissions: [Permission]
	public let UUID: String
	public let leerlingnummer: Int
	public let roepnaam: String
	public let achternaam: String
}

public struct Vak: Decodable {
	public let links: [Link]
	public let permissions: [Permission]
	public let afkorting: String
	public let naam: String
}

public struct AfspraakType: Decodable {
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

public struct AuthToken: Decodable {
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

public struct Organisations: Decodable {
	public let instellingen: [Organisation]
}

public struct Organisation: Decodable {
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

public struct OIDCUrl: Decodable {
	public let omschrijving: String
	public let url: String
	public let domain_hint: String

	public init(omschrijving: String, url: String, domain_hint: String) {
		self.omschrijving = omschrijving
		self.url = url
		self.domain_hint = domain_hint
	}
}