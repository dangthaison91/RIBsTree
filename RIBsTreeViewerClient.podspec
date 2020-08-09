Pod::Spec.new do |s|
  s.name             = 'RIBsTreeViewerClient'
  s.version          = '0.1'
  s.summary          = 'Real time RIB Tree for Uber\'s cross-platform mobile architecture.'
  s.description      = <<-DESC
RIBs is the cross-platform architecture behind many mobile apps at Uber. This architecture framework is designed for mobile apps with a large number of engineers and nested states.
                       DESC
  s.homepage         = 'https://github.com/dangthaison91/RIBsTreeViewerClient'
  s.license          = { :type => 'MIT License, Version 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'dangthaison91' => 'dangthaison.91@gmail.com' }
  s.source           = { :git => 'https://github.com/dangthaison91/RIBsTreeViewerClient.git', :tag => 'v' + s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'RIBsTreeViewerClient/Sources/**/*'
  s.dependency 'RxSwift', '~> 5.1'
  s.dependency 'RxRelay', '~> 5.1'
  s.dependency 'RIBs', :git => 'https://github.com/dangthaison91/RIBs.git', :branch => 'master'
end
