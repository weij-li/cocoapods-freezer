# cocoapods-freezer

cocoapods-freezer is a plugin of cocoapods. It uses for cache of intergation!

## Installation

    $ gem install cocoapods-freezer

## Usage

Configurate such as example, then call 'pod install'.
	
``` ruby
#use_framework! Freezer dont support framework now!

use_freezer!
# use_freezer! :options => {
#	:all => true #or false (default is true)
# }

target 'Demo' do
  pod 'AFNetworking'
end

```

Appreciate a 🌟 if you like it. 