---
title: A guide through decoding in Elm
tags: [decoders,elm,guide]
date: 21-11-2021
---

Decoding is probably one of the trickiest part of Elm Language, where most people normally struggle for a while and a very important part of the Elm knowledge that sometimes is difficult to understand/lear.

I've tried to gather in this document what I believe are the most common situations that can happen while decoding any JSON structure, explained with examples, to help the reader understand them better and help them in the process of building the different decoders into their own structures within Elm.

## What's a decoder?

_This initial part is partially extracted from [JSON Effects in Elm Guide](https://guide.elm-lang.org/effects/json.html) where decoders are really well explained._

When we are writing any language (ruby/javascript/python), and we want to parse a JSON, we do something like:

`JSON.parse(json_string)`

When we do this, have no guarantees about any of the information here. The server can change the names of fields, and the fields may have different types in different situations.
It is a wild world!

In JavaScript, the approach is to just turn JSON into JavaScript objects and hope nothing goes wrong.
But if there is some typo or unexpected data, you get a runtime exception somewhere in your code. Was the code wrong? Was the data wrong? It is time to start digging around to find out!

In Elm, we validate the JSON before it comes into our program. So if the data has an unexpected structure, we learn about it immediately.
There is no way for bad data to sneak through and cause a runtime exception three files over. This is accomplished with JSON decoders.

I like thinking of JSON Decoders as blueprints that describe the JSON that is going to be received in your program.

Let's keep in mind the following object for now:

```JSON
{ name: "Tom",
  age: 25
}
```

## Simple decoding

If we wanted to extract only the name of the person we could create a decoder with the following shape:

```ELm
import JSON.Decoder as D

nameDecoder : D.Decoder String
nameDecoder =
	D.field "name" D.string
```

`field` function is telling us that is going to find inside the JSON stucture the key that we tell them as first parameter `name` and then, as second parameter the function that explains which kind of structure needs to decode, in this case `string`.

There are two major facts to understand in this function:
- Decoders don't get anything passed as parameter, they are not executed yet, they are only descriptions of the object that we are going to decode, and when executed are doing with the following way:
		`D.decodeString decoderToBeExecuted jsonString`
		or
		`D.decodeValue decoderToBeExecuted jsonValue`
- The signature of a Decoder  (in this case `D.Decoder String`)  expresses ultimately which structure we would be decoding into. In this case, `nameDecoder` would return a String when executed as previously explained.

## Normal decoding mapings based on records

So now imagine we still want to keep the previous stated structure within the Elm application, then we would like to define the following record in Elm, been this the equivalent of a JSON object in javascript:

```Elm
type alias Person =
{ name: String
, age: Int
}
```

So now if we were in the previous decoded that we created, it would be nice to do something like:

```ELm
import JSON.Decoder as D

personDecoder : D.Decoder
personDecoder =
	D.field "name" D.string
	D.field "age" D.int
```

Since in Elm everything is a function and in here, we are actually executing two different functions, there are some ways to unify these two decoders into one:


```ELm
import JSON.Decoder as D

personDecoder : D.Decoder String
personDecoder =
	D.map2 Person
		(D.field "name" D.string)
		(D.field "age" D.int)
```

we can use the map functions up to map9, this is map2, map3, map4... , map9, and in case there was more than 9 items in the record you would need to do something like:

```Elm
personWithManyFieldsDecoder : D.Decoder PersonWithManyFields
personWithManyFieldsDecoder =
	D.succeed PersonWithManyFields
        |> D.andThen (\f -> D.map f (field "name" D.string)
        |> D.andThen (\f -> D.map f (field "age" D.int))
		
		-- many other fields here
		
		|> D.andThen (\f -> D.map f (field "some_int" int))
        |> D.andThen (\f -> D.map f (field "some_date" date))
```

Since this is quite verbose and complex there are two alternatives to approach this in a more idiomatic way:

- Using the [elm-community/json-extra](https://package.elm-lang.org/packages/elm-community/json-extra/latest/Json-Decode-Extra#andMap), making the code look something like:

```Elm
import JSON.Decoder as D
import JSON.Decoder.Extra as DE

personWithManyFieldsDecoder : D.Decoder PersonWithManyFields
personWithManyFieldsDecoder =
	D.succeed PersonWithManyFields
        |> DE.andMap (field "name" D.string)
        |> DE.andMap (field "age" D.int)
		
		-- many other fields here
		
		|> DE.andMap (field "some_int" int)
        |> DE.andMap (field "some_date" date)
```

- Using the library that we've been using historicaly in the company and another very good library that achieves the same is [NoRedInk/elm-json-decode-pipeline](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/Json.Decode.Pipeline) and it would look like:

```ELm
import JSON.Decoder as D
import JSON.Decode.Pipeline as DP

personWithManyFieldsDecoder : D.Decoder PersonWithManyFields
personWithManyFieldsDecoder =
	D.succeed Person
		|> DP.required "name" D.string
		|> DP.required "age" D.int
		
		-- many other fields here
		
		|> DP.required (field "some_int" int)
        |> DP.required (field "some_date" date)
```

## Decoding Null values

Let's think about a particular situation.
There might times where some of this information sometimes doesn't exist, sometimes the information is incomplete or it is not required to actually model the whole data.

This has been normally represented in many languages as the concept of [null. Here its creator talks about this more profoundly](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/)

One of the tradeoffs of using null, is that we can let code that shouldn't be executing go through, and evaluating expressions as if there was something, but in reality it isn't.

In Elm the possibility of absence of a value can be modeled as a [Maybe value instead.](https://guide.elm-lang.org/error_handling/maybe.html) Avoiding the possibility of null values go through, enforcing to cover both cases everytime you deal with a Maybe structure.

Keeping the previous example before, imagine that we have the following structure:

```Elm
type alias Person =
	{ name: String
	, age: Maybe Int
	}
```

Before all fields were mandatory (there couldn't be a null in our JSON in order to be decoded), but now this has slightly changed.
Now our `Person` structure does have a possible value, that might or might not exist when decoding a JSON structure.

If we want to decode this new structure, the decoder will look like:

```ELm
import JSON.Decoder as D

personDecoder : D.Decoder String
personDecoder =
	D.map2 Person
		(D.field "name" D.string)
		(D.field "age" (D.nullable D.int))
```

or with the `NoRedInk/elm-json-decode-pipeline` syntax:

```ELm
import JSON.Decoder as D

personDecoder : D.Decoder String
personDecoder =
	D.succeed Person
		|> D.required "name" D.string
		|> D.required "age" (D.nullable D.int)
```

### Inconsistent structures decoder

With the previous situation in mind, maybe not only the value is inconsistent but also, the key might be too.
Imagine now the answers can be:

```JSON
{
	name: "nameOfAPerson"
}
-- or
{
	name: "nameOfAPerson",
	age: 53
}
-- or even
{
	name: "nameOfAPerson",
	age: null
}

```

How do we handle this in Elm?
Well let's see now how the decoder is written now:

```ELm
import JSON.Decoder as D

personDecoder : D.Decoder String
personDecoder =
	D.map2 Person
		(D.field "name" D.string)
		(D.maybe (D.field "age" (D.nullable D.int)))

```

or with the `NoRedInk/elm-json-decode-pipeline` syntax, here the reference to the [docs](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/Json-Decode-Pipeline#optional):

```ELm
import JSON.Decoder as D

personDecoder : D.Decoder String
personDecoder =
	D.succeed Person
		|> D.required "name" D.string
		|> D.optional "age" (D.nullable D.int) Nothing
```

This way, we would ensure that no matter the structure of the JSON, you can always represent this structure in Elm. [Here you can see the actual docs of Maybe](https://package.elm-lang.org/packages/elm/core/latest/Maybe) that might be useful to understand all of these better.

## Decode Different versions of a JSON

Another situation when decoding, when you have changed your data structure, let's say, initially you had:

```ELm
import JSON.Decoder as D

type alias Person =
	{ name : String
	, age : Maybe Int
	}

personDecoder : D.Decoder Person
personDecoder =
	D.map2 Person
		(D.field "name" D.string)
		(D.maybe (D.field "age" (D.nullable D.int)))

```

and after sometime, the requirements of your API changes in one of the endpoints and now some of the endpoints are serving a new value `address`, this way we can support both endpoints at the same time:

```Elm

type alias PersonV2 =
	{ name : String
	, age : Maybe Int
	, address : Maybe String
	}
```

to keep the API working, you can do something like:

```Elm
personV1Decoder : D.Decoder PersonV2
personV1Decoder =
	D.map3 PersonV2
		(D.field "name" D.string)
		(D.field "age" (D.nullable D.int)
		(D.null Nothing)
		
personV2Decoder : D.Decoder PersonV2
personV2Decoder =
	D.map3 PersonV2
		(D.field "name" D.string)
		(D.field "age" (D.nullable D.int))
		(D.field "address" (D.nullable D.string))
		
personDecoder : D.Decoder PersonV2
personDecoder =
	D.oneOf [personV2Decoder, personV1Decoder]

```

Note: as you could have probably think aready, this could be also be written directly as:

```Elm
personDecoder : D.Decoder PersonV2
personDecoder =
	D.map3 PersonV2
		(D.field "name" D.string)
		(D.field "age" (D.nullable D.int)
		(D.maybe (D.field "address" (D.nullable D.string)))
	
```

## Decoding and map into types

When you are used to work with Elm, there are many times when you want to encapsulate information around types, [here is a good talk about why this is interesting](https://www.youtube.com/watch?v=IcgmSRJHu_8).

When doing this, it's not so clear how we could implement a decoder.
Imagine we have the following code:

```Elm
	type Person 
		= MinorPerson String
		| AdultPerson String
```

We want a `MinorPerson` to represent someone which age is under 18 but an `AdultPerson` would be someone who is over that age integer number.

Let's now a create a decoder that cover this case:

```ELm
import JSON.Decoder as D

personTypedDecoder : D.Decoder Person
personTypedDecoder =
	D.field "age" D.int
		|> D.andThen (\age ->
			if age < 18 then
				D.map MinorPerson (D.field "name" D.string)
			else
				D.map AdultPerson (D.field "name" D.string)
		)
```

This gets a little bit more complex now, what is happening here is that you need to **decode age first** in order to get the information to actually choose between a MinorPerson and an AdultPerson, so we do that by decoding that information first.
Then `andThen` function, let us access the information previously decoded, and then let us decode the rest of the object based on that information, in this case `age`.

Then, the `map` function, let us build the types as if it was a constructor (which it is), by mapping the decoder of the field `name` into the constructor of Person `MinorPerson` and `AdultPerson`.

### Decoding dependant structures with `andThen` within a record

The previous idea can be done at all levels, imagine that `Person` now lives within a record, and not as an isolated entity, let's say now our person is:

```Elm
type Person 
	= MinorPerson String
	| AdultPerson String
	
-- and now we have

type alias PersonInformation =
	{ person : Person
	, address : String
	, identityNumber : String
	}

```

and the JSON coming from the backend it is something like:

```JSON
{
	name: "NameOfThePerson",
	age: 32,
	address: "AddressOfThePerson",
	id_number: "54323J"
}
```

If we were to build now the decoder, it would have the following shape (to simplify mapping, I will use `NoRedInk/elm-json-decode-pipeline`):

```Elm
personInformationDecoder : D.Decoder PersonInformation
personInformationDecoder =
	D.succeed PersonInformation
		|> D.required "age"
			(D.String 
				|> D.andThen (\age ->
					if age < 18 then
						D.map MinorPerson (D.field "name" D.string)
					else
						D.map AdultPerson (D.field "name" D.string)
			)
		|> D.required "adress" D.string
		|> D.required "id_number" D.string

```

## Decoding lists
Normally when modelling any of these decoders, it is likely that we are not only decoding one element. Normally we are decoding multiple elements into a different structure.

The most common structure possibly is a list of these elements, let's go through how it would be to become any previous decoder into a `D.Decoder List something`

Using the previous `personInformationDecoder`:

If we would like decode a list of these elements we could create the decoder the following way:

```Elm
personInformationListDecoder : D.Decoder (List PersonInformation)
personInformationListDecoder =
	(D.succeed PersonInformation
		|> D.required "age"
			(D.String 
				|> D.andThen (\age ->
					if age < 18 then
						D.map MinorPerson (D.field "name" D.string)
					else
						D.map AdultPerson (D.field "name" D.string)
			)
		|> D.required "adress" D.string
		|> D.required "id_number" D.string)
		|> D.list
```

or we we want to reuse the previous function:

```Elm
personInformationListDecoder : D.Decoder (List PersonInformation)
personInformationListDecoder =
	personDecoder
		|> D.list
```

## Transform a list into a dictonary
There are situations where we don't want to store the information into a list, but maybe as a Dictionary instead, this is because we do not need to keep the order (List maintain order, Dicts don't), but we care about fast access when using the information within the structure.

Let's transform the previous decoder, by using the `id_number` which we have previously described as unique (so it can serve us as a key for the `Dict`) into a `D.Decoder Dict PersonInformation`.

```Elm
personInformationListDecoder : D.Decoder (List PersonInformation)
personInformationListDecoder =
	(D.succeed PersonInformation
		|> D.required "age"
			(D.String 
				|> D.andThen (\age ->
					if age < 18 then
						D.map MinorPerson (D.field "name" D.string)
					else
						D.map AdultPerson (D.field "name" D.string)
			)
		|> D.required "adress" D.string
		|> D.required "id_number" D.string)
		|> D.list

		--- Same decoder as before but know we need to make it a dictionary

		|> D.andThen(\people ->
			people
				|> List.map (\person -> (person.identityNumber, person))
				|> Dict.fromList
				|> D.succeed
		)
```

## Decoding key-value objects

We just saw how it is to decode a list of elements, or how we can get the values and then map it into a Dict. Other times, maybe, the structure is already served within a JSON object, like this:

```JSON
{
	"54323J": {
		name: "NameOfThePerson",
		age: 32,
		address: "AddressOfThePerson",
	},
	"53212Y" : {
		name: "NameOfAnotherPerson",
		age: 12,
		address: "AddressOfAnotherPerson",
	},
}
```

We assume here, like in the previous example, that the id number of this person (a  unequivocally distinctive value) is the key of our json and we can map it into a dictionary the following way:

```Elm
import JSON.Decoder as D

type alias Person =
	{ name : String
	, age : Int
	, address : String
	}
```

```Elm
personTypedDecoder : D.Decoder (Dict String Person)
personTypedDecoder =
	D.keyValuePairs
		(D.map3 Person
			(D.field "name" D.string)
			(D.field "age" D.int)
			(D.field "address" D.string))
```


## Decoding dependant structures based on the key of a key-value object (how the list decoding works)

We found in the previous example how easy is to decode a structure like `{id: value}` in Elm, but what would it happen if the value is dependant to the id?

Imagine that we previously have some data about the people based on the id and in order to decode the `personInformation`, we need to access that data to do the decoding. To do this, we can avoid decoding in the first place, by using the decoder [D.value](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#value) keeping the dictionary data as a JSON still without decoding it, and then when we have the information, from the `id` in a second step, decode the [JSON Value](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#value) (anchor in the page doesn't correctly work, scroll to `type Value`).

Now as before with the same data shape:

```JSON
{
	"54323J": {
		name: "NameOfThePerson",
		age: 32,
		address: "AddressOfThePerson",
	},
	"53212Y" : {
		name: "NameOfAnotherPerson",
		age: 12,
		address: "AddressOfAnotherPerson",
	},
}
```

Imagine we want to the code something with the shape of:

```Elm
import JSON.Decoder as D

type alias PersonId = String

type alias Person =
	{ name : String
	, age : Int
	, address : String
	, otherData : OtherData
	}
	
--- and we have in our model
--- { otherDataDict : Dict PersonId OtherData }
```

Then we can structure our decoder the following way, now we pass the dict where we store the data about the people to the decoder to be able to use it in the decoding process:

```Elm
personDictDecoder : Dict PersonId OtherData -> D.Decoder (Dict PersonId Person)
personDictDecoder otherDataDict =
	D.keyValuePairs D.value
	
		-- we decode the ids first and then
		
		|> D.andThen (\listOfPeopleIds-> 
			List.filterMap (\(personId, personValue) -> 
				case Dict.get personId otherDataDict of
					Just personData ->
						case D.decodeValue (personDecoder personData) personValue of
							Ok decodedPerson ->
								Just (id, decodedPerson) 
							Err _ ->
								Nothing 
					Nothing -> Nothing ) listOfPeopleIds 
			|> D.succeed
		)
```

where `personDecoder` is:

```Elm

personDecoder : OtherData -> D.Decoder Person
personDecoder otherData =
	D.map4 Person
		(D.field "name" D.string)
		(D.field "age" D.int)
		(D.field "address" D.string)
		(D.succeed otherData)
```


### Note: Making decoder actually aware of the error

Sometimes there are some errors happening within the inner decoder in D.decodeValue, since we are doing a `filterMap` in the previous decoding, we are removing all the errors from the decoding steps.

A possibility (although might not be the best) to keep the error either from the `Dict PersonId OtherData` when doing the Dict.get, i.e. there is no information about that person in the Dict or from the `D.decodeValue (personDecoder personData) personValue` can be, to keep the `Maybe`s withing the array by using a map instead and then if any `Nothing` is still in the list, that means there was some of the branches that couldn't succeed, and we can raise an error for the integrity of the decoded data this way:

```Elm
personDictDecoder : Dict PersonId OtherData -> D.Decoder (Dict PersonId Person)
personDictDecoder otherDataDict =
	D.keyValuePairs D.value
	
		-- we decode the ids first and then
		
		|> D.andThen (\listOfPeopleIds->
			let
				listOfDecodedPeople = 
					List.map (\(personId, personValue) -> 
						case Dict.get personId otherDataDict of
							Just personData ->
								case D.decodeValue (personDecoder personData) personValue of
									Ok decodedPerson ->
										Just (id, decodedPerson) 
									Err _ ->
										Nothing 
							Nothing -> Nothing ) listOfPeopleIds 
			in
			if List.any (\person -> person == Nothing) listOfDecodedPeople then
			 	D.fail "There was some error decoding the people"  
			 else  
			 	listOfDecodedPeople
				
					-- we remove the maybes with this map

					|> List.filterMap identity  
					|> D.succeed  
		)
```

