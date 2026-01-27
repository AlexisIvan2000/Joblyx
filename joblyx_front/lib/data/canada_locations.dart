// Provinces canadiennes
const List<String> canadaProvinces = [
  'Alberta',
  'British Columbia',
  'Manitoba',
  'New Brunswick',
  'Newfoundland and Labrador',
  'Northwest Territories',
  'Nova Scotia',
  'Nunavut',
  'Ontario',
  'Prince Edward Island',
  'Quebec',
  'Saskatchewan',
  'Yukon',
];

// Villes principales par province
const Map<String, List<String>> canadaCitiesByProvince = {
  'Alberta': [
    'Calgary', 'Edmonton', 'Red Deer', 'Lethbridge', 'Medicine Hat',
    'Grande Prairie', 'Airdrie', 'Fort McMurray', 'Spruce Grove', 'Leduc',
  ],
  'British Columbia': [
    'Vancouver', 'Victoria', 'Burnaby', 'Surrey', 'Richmond', 'Kelowna',
    'Abbotsford', 'Coquitlam', 'Langley', 'Nanaimo', 'Kamloops', 'Prince George',
  ],
  'Manitoba': [
    'Winnipeg', 'Brandon', 'Steinbach', 'Thompson', 'Portage la Prairie',
    'Selkirk', 'Winkler', 'Dauphin',
  ],
  'New Brunswick': [
    'Moncton', 'Saint John', 'Fredericton', 'Dieppe', 'Miramichi',
    'Edmundston', 'Bathurst', 'Campbellton',
  ],
  'Newfoundland and Labrador': [
    "St. John's", 'Mount Pearl', 'Corner Brook', 'Conception Bay South',
    'Paradise', 'Grand Falls-Windsor', 'Gander', 'Labrador City',
  ],
  'Northwest Territories': [
    'Yellowknife', 'Hay River', 'Inuvik', 'Fort Smith', 'Behchoko',
  ],
  'Nova Scotia': [
    'Halifax', 'Dartmouth', 'Sydney', 'Truro', 'New Glasgow',
    'Glace Bay', 'Kentville', 'Amherst', 'Bridgewater',
  ],
  'Nunavut': [
    'Iqaluit', 'Rankin Inlet', 'Arviat', 'Baker Lake', 'Cambridge Bay',
  ],
  'Ontario': [
    'Toronto', 'Ottawa', 'Mississauga', 'Brampton', 'Hamilton', 'London',
    'Markham', 'Vaughan', 'Kitchener', 'Windsor', 'Richmond Hill', 'Oakville',
    'Burlington', 'Oshawa', 'Barrie', 'St. Catharines', 'Cambridge', 'Kingston',
    'Guelph', 'Thunder Bay', 'Waterloo', 'Brantford', 'Pickering', 'Niagara Falls',
  ],
  'Prince Edward Island': [
    'Charlottetown', 'Summerside', 'Stratford', 'Cornwall', 'Montague',
  ],
  'Quebec': [
    'Montreal', 'Quebec City', 'Laval', 'Gatineau', 'Longueuil', 'Sherbrooke',
    'Trois-Rivières', 'Saguenay', 'Lévis', 'Terrebonne', 'Repentigny',
    'Saint-Jean-sur-Richelieu', 'Brossard', 'Drummondville', 'Saint-Jérôme',
    'Granby', 'Blainville', 'Saint-Hyacinthe', 'Shawinigan', 'Dollard-des-Ormeaux',
    'Rimouski', 'Victoriaville', 'Chicoutimi', 'Alma', 'Rouyn-Noranda',
  ],
  'Saskatchewan': [
    'Saskatoon', 'Regina', 'Prince Albert', 'Moose Jaw', 'Swift Current',
    'Yorkton', 'North Battleford', 'Estevan', 'Weyburn', 'Lloydminster',
  ],
  'Yukon': [
    'Whitehorse', 'Dawson City', 'Watson Lake', 'Haines Junction',
  ],
};

// Toutes les villes triées
List<String> get allCanadaCities {
  return canadaCitiesByProvince.values.expand((cities) => cities).toList()..sort();
}

// Obtenir les villes d'une province
List<String> getCitiesForProvince(String? province) {
  if (province == null) return allCanadaCities;
  return canadaCitiesByProvince[province] ?? [];
}
