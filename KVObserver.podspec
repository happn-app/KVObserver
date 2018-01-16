Pod::Spec.new do |spec|
	spec.name = "KVObserver"
	spec.version = "1.0.0"
	spec.summary = "The logger we use at happn"
	spec.homepage = "<#YOUR HOMEPAGE#>"
	spec.license = {type: '<#YOUR LICENSE TYPE#>', file: '<#PATH TO YOUR LICENSE FILE#>'}
	spec.authors = {"François Lamboley" => 'francois.lamboley@happn.com'}
	spec.social_media_url = "<#YOUR SOCIAL MEDIA URL#>"

	spec.requires_arc = true
	spec.source = {git: "<#GIT URL#>", <#BRANCH, TAG OR OTHER VERSION POINTER#>}
	spec.source_files = "Sources/KVObserver/*.swift"

	spec.ios.deployment_target = '8.0'
	spec.osx.deployment_target = '10.9'
	spec.tvos.deployment_target = '9.0'
	spec.watchos.deployment_target = '2.0'

#	spec.dependency "Example", "~> 1.4.0"
end
