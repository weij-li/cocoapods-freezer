# cocoapods-freezer

cocoapods-freezer is a plugin of cocoapods. It uses for cache of intergation!

## Foreword

Too many source code of 3rd Pods is a reason of reduced integration speed. Versions of 3rd Pods maintain stability, and the same to the product of 3rd Pods. Maybe we can integate with products of cache. 

## Installation

``` shell
$ gem install cocoapods-freezer
```

## Usage

``` shell
$ pod install --frozen

$ pod install --frozen=/Users/vakeeeli/FrozenPods

```

## Principle

Cocoapods-freezer will cache the product which Pods pre-build before Pods integate (`pod install`). Then it use cache for integate.

Appreciate a 🌟 if you like it. 
