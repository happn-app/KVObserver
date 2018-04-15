Pod::Spec.new do |spec|
	spec.name = "KVObserver"
	spec.version = "0.9.2"
	spec.summary = "A safer KVO"
	spec.homepage = "https://www.happn.com/"
	spec.license = {type: 'TBD', file: 'License.txt'}
	spec.authors = {"François Lamboley" => 'francois.lamboley@happn.com'}
	spec.social_media_url = "https://twitter.com/happn_tech"

	spec.requires_arc = true
	spec.source = {git: "git@github.com:happn-app/KVObserver.git", tag: spec.version}
	spec.source_files = "Sources/KVObserver/*.swift"

	spec.ios.deployment_target = '8.0'
	spec.osx.deployment_target = '10.9'
	spec.tvos.deployment_target = '9.0'
	spec.watchos.deployment_target = '2.0'
end
