Require Import List.
Import ListNotations.

Section Monad.
  Variable M : Type -> Type.

  Class Map : Type := {
    map : forall (A B : Type), M A -> (A -> B) -> M B
  }.

  Class Bind : Type := {
    bind : forall (A B : Type), M A -> (A -> M B) -> M B
  }.

  Class Both : Type := {
    both : forall (A B : Type), M A -> M B -> M (A * B)
  }.

  Class Return : Type := {
    ret : forall (A : Type), A -> M A
  }.

  Class Join : Type := {
    join : forall (A : Type), M (M A) -> M A
  }.

  Class Ignore_m : Type := {
    ignore_m : forall (A : Type), M A -> M unit
  }.

  Class All : Type := {
    all : forall (A : Type), list (M A) -> M (list A)
  }.
End Monad.

Arguments map {M Map A B} _ _.
Arguments bind {M Bind A B} _ _.
Arguments both {M Both A B} _ _.
Arguments ret {M Return A} _.
Arguments join {M Join A} _.
Arguments ignore_m {M Ignore_m A} _.
Arguments all {M All A} _.

Section Instances.
  Context {M : Type -> Type}.

  Instance map_of_bind `{Bind M} `{Return M} : Map M | 0 := {
    map := fun A B ma f => bind ma (fun a => ret (f a))
  }.

  Instance both_ `{Bind M} `{Map M} : Both M := {
    both := fun A B ma mb =>
      bind ma (fun a => map mb (fun b => (a, b)))
  }.

  Instance join_ `{Bind M} : Join M := {
    join := fun A mma => bind mma (fun ma => ma)
  }.

  Instance ignore_m_ `{Map M} : Ignore_m M := {
    ignore_m := fun A ma => map ma (fun ma => tt)
  }.

  Instance all_ `{Bind M} `{Return M} : All M := {
    all := fun A =>
      let all := fix all rev lma :=
        match lma with
        | [] => ret (List.rev rev)
        | a :: lma => bind a (fun a => all (a :: rev) lma)
        end in
      all []
  }.
End Instances.