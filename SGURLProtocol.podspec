Pod::Spec.new do |s|
	s.name = 'SGURLProtocol'
	s.version = '0.0.1'
	s.summary = 'Custom CFHTTPMessage based NSURLProtocol subclass, for supporting HTTP Authentication with UIWebiView'
	s.author = {
		'Simon Grätzer' => 'simon@graetzer.org',
		'Dallin Lauritzen' => 'dallin.lauritzen@parentlink.net'
	}
	s.source = {
		:git => 'https://github.com/ParlantTechnology/SGURLProtocol.git',
		:tag => s.version.to_s
	}
	s.source_files = 'SGURLProtocol/*'
end