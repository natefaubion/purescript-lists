module Data.List.NonEmpty
  ( module Data.List.Types
  , toUnfoldable
  , fromFoldable
  , fromList
  , toList
  , singleton
  , head
  , last
  , tail
  , init
  , uncons
  , length
  , concatMap
  , appendFoldable
  , sort
  , sortBy
  ) where

import Prelude

import Data.Foldable (class Foldable)
import Data.List ((:))
import Data.List as L
import Data.List.Types (NonEmptyList(..))
import Data.Maybe (Maybe(..), maybe, fromMaybe, fromJust)
import Data.NonEmpty ((:|))
import Data.NonEmpty as NE
import Data.Tuple (Tuple(..))
import Data.Unfoldable (class Unfoldable, unfoldr)
import Partial.Unsafe (unsafePartial)

toUnfoldable :: forall f. Unfoldable f => NonEmptyList ~> f
toUnfoldable =
  unfoldr (\xs -> (\rec -> Tuple rec.head rec.tail) <$> L.uncons xs) <<< toList

fromFoldable :: forall f a. Foldable f => f a -> Maybe (NonEmptyList a)
fromFoldable = fromList <<< L.fromFoldable

fromList :: forall a. L.List a -> Maybe (NonEmptyList a)
fromList L.Nil = Nothing
fromList (x : xs) = Just (NonEmptyList (x :| xs))

toList :: NonEmptyList ~> L.List
toList (NonEmptyList (x :| xs)) = x : xs

singleton :: forall a. a -> NonEmptyList a
singleton = NonEmptyList <<< NE.singleton

head :: forall a. NonEmptyList a -> a
head (NonEmptyList (x :| _)) = x

last :: forall a. NonEmptyList a -> a
last (NonEmptyList (x :| xs)) = fromMaybe x (L.last xs)

tail :: NonEmptyList ~> L.List
tail (NonEmptyList (_ :| xs)) = xs

init :: NonEmptyList ~> L.List
init (NonEmptyList (x :| xs)) = maybe L.Nil (x : _) (L.init xs)

uncons :: forall a. NonEmptyList a -> { head :: a, tail :: L.List a }
uncons (NonEmptyList (x :| xs)) = { head: x, tail: xs }

length :: forall a. NonEmptyList a -> Int
length (NonEmptyList (x :| xs)) = 1 + L.length xs

concatMap :: forall a b. (a -> NonEmptyList b) -> NonEmptyList a -> NonEmptyList b
concatMap = flip bind

appendFoldable :: forall t a. Foldable t => NonEmptyList a -> t a -> NonEmptyList a
appendFoldable (NonEmptyList (x :| xs)) ys =
  NonEmptyList (x :| (xs <> L.fromFoldable ys))

sort :: forall a. Ord a => NonEmptyList a -> NonEmptyList a
sort xs = sortBy compare xs

sortBy :: forall a. (a -> a -> Ordering) -> NonEmptyList a -> NonEmptyList a
sortBy cmp xs = unsafeFromList $ L.sortBy cmp (toList xs)
  where unsafeFromList ys = unsafePartial $ fromJust $ fromList ys
