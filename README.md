# 🌐 Social Network Graph Analysis with Neo4j

## 📌 Overview

This project implements a Graph Database Model for a Social Network using Neo4j.
The goal is to provide insights into user engagement, content popularity, and social connections such as friendships, communities, and interactions with posts.

The system uses Cypher queries to answer complex questions about user behavior, shortest paths, recommendations, and community discovery.

## 🧩 Problem Statement

A social media analytics startup wants to develop a product capable of understanding engagement patterns and connections between users across the platform.

They need a functional prototype that can answer complex questions such as:

- How users interact with content
- Which posts receive the most attention
- How users are connected to one another
- What communities are formed inside the platform

This prototype must use graph-based modeling to make these insights efficient and intuitive.

## 🎯 Challenge

Using graph modeling principles, you must design, build, and query a complete Neo4j database that represents a social network — including users, posts, comments, groups, and communities.

## 📐 Graph Data Model

### Node Labels

- Person
- Post
- Comment
- Data
- Group
- Community

### Relationships

- `(:Person)-[:FOLLOWS]->(:Person)`
- `(:Person)-[:POSTED]->(:Post) `
- `(:Person)-[:LIKED]->(:Post)`
- `(:Post)-[:CREATED_ON]->(:Data)` 
- `(:Person)-[:WRITE]->(:Comment)`
- `(:Comment)-[:ON_DATE]->(:Data)` 
- `(:Person)-[:MEMBER_OF]->(:Group)` 
- `(:Group)-[:PART_OF]->(:Community)`

This graph allows deep insights into relationships, influence, popularity, and connection paths.

## 🧱 Data Model Diagram

![Social Media System Graph Model](social_media_graph.png)

# 🔍 Useful Cypher Queries

## ⭐ 1. RECOMENDAÇÃO DE POSTS

### ✅ 1.1 Posts curtidos por pessoas que o usuário segue

Recomenda posts que pessoas seguidas curtiram, mas que o usuário ainda não curtiu.

```cypher
MATCH (u:Person {name: "Juliana"})-[:FOLLOWS]->(friend)
MATCH (friend)-[:LIKED]->(p:Post)
WHERE NOT (u)-[:LIKED]->(p)
RETURN p, friend.name AS recommended_by
LIMIT 10;
```

### ✅ 1.2 Posts comentados por pessoas que o usuário segue

```cypher
MATCH (u:Person {name: "Laura"})-[:FOLLOWS]->(friend)
MATCH (friend)-[:WROTE]->(:Comment)-[:ON_POST]->(p:Post)
WHERE NOT (u)-[:LIKED]->(p)
RETURN p, friend.name AS recommended_by
LIMIT 10;
```

### ✅ 1.3 Posts populares na comunidade do usuário

```cypher
MATCH (u:Person {name: "Laura"})-[:PART_OF]->(c:Community)
MATCH (c)<-[:PART_OF]-(other:Person)-[:POSTED]->(p:Post)
RETURN p, other.name AS from_user_in_community
ORDER BY p.id DESC
LIMIT 10;
```

### ✅ 1.4 Posts com mais curtidas recentemente

```cypher
MATCH (p:Post)<-[:LIKED]-(:Person)
WITH p, COUNT(*) AS likes
RETURN p, likes
ORDER BY likes DESC
LIMIT 10;
```

## ⭐ 2. RECOMENDAÇÃO DE USUÁRIOS

### ✅ 2.1 Pessoas seguidas pelos amigos (Follow do Follow)


```cypher
MATCH (u:Person {name: "Laura"})-[:FOLLOWS]->(f)-[:FOLLOWS]->(rec:Person)
WHERE u <> rec AND NOT (u)-[:FOLLOWS]->(rec)
RETURN DISTINCT rec
LIMIT 10;
```

### ✅ 2.2 Pessoas com interesses ou comunidades em comum

```cypher
MATCH (u:Person {name: "Laura"})-[:PART_OF]->(c:Community)
MATCH (other:Person)-[:PART_OF]->(c)
WHERE other <> u
RETURN DISTINCT other, c.name AS same_community
LIMIT 10;
```

# 🔍 Rodar Node Similarity para encontrar usuários parecidos

## 🔧 Criar grafo projetado

```cypher
CALL gds.graph.project(
  'socialGraph',
  ['Person', 'Post', 'Comment'],
  {
    FOLLOWS: { type: 'FOLLOWS', orientation: 'UNDIRECTED' },
    LIKED:   { type: 'LIKED', orientation: 'UNDIRECTED' },
    WROTE:   { type: 'WROTE', orientation: 'UNDIRECTED' },
    POSTED:  { type: 'POSTED', orientation: 'UNDIRECTED' },
    ON_POST: { type: 'ON_POST', orientation: 'UNDIRECTED' }
  }
);

```

## ✔️ Execução do algoritmo

```cypher
CALL gds.nodeSimilarity.write(
  'socialGraph',
  {
    nodeLabels: ['Person'],
    writeRelationshipType: 'SIMILAR_TO',
    writeProperty: 'score'
  }
);
```

### ✅ Ver os usuários mais similares

```cypher
MATCH (u:Person {name: "Diego"})-[s:SIMILAR_TO]->(other)
RETURN other.name AS similarUser, s.score
ORDER BY s.score DESC
LIMIT 10;
```

### ✅ Recomendação de usuários baseada em similaridade

```cypher
MATCH (u:Person {id: $userId})-[s:SIMILAR_TO]->(other)
WHERE NOT (u)-[:FOLLOWS]->(other)
RETURN other.name AS recommendedUser, s.score
ORDER BY s.score DESC
LIMIT 10;
```

### ✅ Recomendação de posts usando usuários similares

```cypher
MATCH (u:Person {id: $userId})-[s:SIMILAR_TO]->(other)
MATCH (other)-[:LIKED]->(p:Post)
WHERE NOT (u)-[:LIKED]->(p)
RETURN p, other.name AS similarUser, s.score
ORDER BY s.score DESC
LIMIT 10;

```
