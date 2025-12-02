CREATE CONSTRAINT person_id IF NOT EXISTS
FOR (p:Person) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT post_id IF NOT EXISTS
FOR (p:Post) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT group_id IF NOT EXISTS
FOR (g:Group) REQUIRE g.id IS UNIQUE;

CREATE CONSTRAINT genre_id IF NOT EXISTS
FOR (c:Community) REQUIRE c.id IS UNIQUE;


UNWIND [
  {id: 1, name: "Laura", age: 36},
  {id: 2, name: "Carla", age: 35},
  {id: 3, name: "Diego", age: 38},
  {id: 4, name: "Andres", age: 21},
  {id: 5, name: "Carol", age: 32},
  {id: 6, name: "Juliana", age: 38},
  {id: 7, name: "Diana", age: 42},
  {id: 8, name: "Santiago", age: 25},
  {id: 9, name: "Daniel", age: 27},
  {id: 10, name: "Ricardo", age: 40}
] AS userData
CREATE (:Person {id: userData.id, name: userData.name, age: userData.age});

UNWIND [
  {user:1, user2:3}, {user:1, user2:4}, {user:1, user2:5},
  {user:1, user2:6}, {user:1, user2:7}, {user:1, user2:8},
  
  {user:2, user2:3}, {user:2, user2:8},
  {user:2, user2:10},{user:2, user2:7},
  
  {user:3, user2:1}, {user:3, user2:10}, {user:3, user2:9},
  {user:3, user2:8}, {user:3, user2:7},  {user:3, user2:2},
  
  {user:4, user2:1},{user:4, user2:10},{user:4, user2:9},
  {user:4, user2:7},{user:4, user2:2}, {user:4, user2:8},
  
  {user:5, user2:10}, {user:5, user2:9}, {user:5, user2:8},
  {user:5, user2:6}, {user:5, user2:7}, {user:5, user2:3},
  
  {user:6, user2:1}, {user:6, user2:3}, {user:6, user2:5},
  
  {user:7, user2:1}, {user:7, user2:2}, {user:7, user2:4},
  
  {user:8, user2:7}, {user:8, user2:9}, {user:8, user2:10},
  
  {user:9, user2:8}, {user:9, user2:7}, {user:9, user2:5},
  
  {user:10, user2:5}, {user:10, user2:3}, {user:10, user2:1}
  
] AS entry

MATCH (p:Person {id: entry.user})
MATCH (p2:Person {id: entry.user2})
MERGE (p)-[:FOLLOWS]->(p2);


UNWIND [
  {id: "c01", name: "Tech Community"},
  {id: "c02", name: "Fitness Community"},
  {id: "c03", name: "Pet Community"},
  {id: "c04", name: "Neo4j Community"}

] AS CommData
CREATE (:Community {id: CommData.id, name: CommData.name});

UNWIND [
  {id: "g01", name: "NLP Research Group"},
  {id: "g02", name: "AI Designers Group"}

] AS GroupData
CREATE (:Group {id: GroupData.id, name: GroupData.name});

UNWIND [
  {person:1, community: "c01"},
  {person:3, community: "c01"},
  {person:4, community: "c01"},
  {person:8, community: "c01"},
  {person:10, community: "c01"},
  
  {person:2, community: "c02"},
  {person:5, community: "c02"},
  {person:6, community: "c02"},
  {person:7, community: "c02"},
  
  {person:4, community: "c03"},
  {person:9, community: "c03"},
  
  {person:1, community: "c04"},
  {person:3, community: "c04"},
  {person:4, community: "c04"},
  {person:10, community: "c04"}
  
] AS data

MATCH (p:Person {id: data.person}), (c:Community {id: data.community})
MERGE (p)-[:PART_OF]->(c);

UNWIND [
	{person:1, group: "g01"},
	{person:3, group: "g01"},
	{person:4, group: "g01"},
	{person:8, group: "g02"},
	{person:10, group: "g02"}
	
] AS dataG

MATCH (p:Person {id: dataG.person}), (g:Group {id: dataG.group})
MERGE (p)-[:MEMBER_OF]->(g);


UNWIND [
  {year:2025, month:11, day:27}, #post
  {year:2025, month:11, day:28},
  {year:2025, month:11, day:29},
  {year:2025, month:11, day:30}, #post
  {year:2025, month:12, day:1}, #post
  {year:2025, month:12, day:2} #comment
] AS d
CREATE (:Date {year:d.year, month:d.month, day:d.day});

UNWIND [
  {id:101, content:"First post about Neo4j", author:1, date:{year:2025,month:11,day:27}},
  {id:102, content:"Learning GDS is awesome!", author:2, date:{year:2025,month:11,day:30}},
  {id:103, content:"Another post with date", author:2, date:{year:2025,month:12,day:1}}
] AS post

CREATE (p:Post {id: post.id, content: post.content})

WITH post, p

MATCH (u:Person {id: post.author})
MATCH (d:Date {
  year: post.date.year,
  month: post.date.month,
  day: post.date.day
})
MERGE (u)-[:POSTED]->(p)
MERGE (p)-[:CREATED_ON]->(d);

UNWIND [
  {id:201, content:"Nice post!", author:8, post:103, date:{year:2025,month:12,day:2}},
  {id:202, content:"Very helpful, thanks!", author:3, post:102, date:{year:2025,month:12,day:1}},
  {id:203, content:"Neosemantics is a plugin that enables the use of RDF in Neo4j", author:8, post:101, date:{year:2025,month:11,day:29}},
  {id:204, content:"Build Intelligent Apps and AI for fraud detection", author:1, post:102, date:{year:2025,month:11,day:30}},
  {id:205, content:"Nice post, I love it!", author:10, post:101, date:{year:2025,month:11,day:28}}
] AS c

CREATE (cm:Comment {id:c.id, content:c.content})

WITH c, cm
MATCH (u:Person {id:c.author})
MATCH (p:Post {id:c.post})
MATCH (d:Date {
  year: c.date.year,
  month: c.date.month,
  day: c.date.day
})
MERGE (u)-[:WROTE]->(cm)
MERGE (cm)-[:ON_POST]->(p)
MERGE (cm)-[:ON_DATE]->(d);



UNWIND [
  {user:1, post:101 },
  {user:3, post:101 },
  {user:4, post:101 },
  {user:5, post:101 },
  {user:6, post:101 },
  {user:8, post:101 },
  {user:8, post:102 },
  {user:7, post:102 },
  {user:3, post:102 },
  {user:8, post:103 },
  {user:1, post:103 },
  {user:3, post:103 }
  
] AS likeData

MATCH (u:Person {id: likeData.user}), (p:Post {id: likeData.post})

MERGE (u)-[:LIKED]->(p)