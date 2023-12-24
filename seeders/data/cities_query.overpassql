[out:json][timeout:100];
area["name:pl"="Polska"]["admin_level"="2"]->.a;
(
  nwr(area.a)["place"~"^(town|city)$"];
);
out center;
>;
