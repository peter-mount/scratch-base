// Build properties
properties([
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    cron('H H * * *')
  ])
])

// The architectures to build, in format recognised by docker
architectures = [ 'amd64', 'arm64v8' ]

// Repository name use, must end with / or be '' for none
repository= 'area51/'
// Disable deployment until it's known to work
//repository=''

// image prefix
imagePrefix = 'scratch-base'

// The image version, master branch is latest in docker
version=BRANCH_NAME
if( version == 'master' ) {
  version = 'latest'
}

// The docker image name
// architecture can be '' for multiarch images
def dockerImage = {
  architecture -> repository + imagePrefix +
    ':' +
    ( architecture=='' ? '' : (architecture + '-') ) +
    version
}

// The build slaves for each architecture
def buildslave = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'AMD64'
    case 'arm64v8':
      return 'ARM64'
    default:
      return architecture
  }
}

// The go arch
def goarch = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'amd64'
    case 'arm32v6':
    case 'arm32v7':
      return 'arm'
    case 'arm64v8':
      return 'arm64'
    default:
      return architecture
  }
}

// The multi arch image name
multiImage = repository + imagePrefix + ':' + version

// Now build everything on one node
architectures.each {
  architecture -> node( buildslave( architecture ) ) {
    stage( architecture ) {
      checkout scm

      sh 'docker pull alpine'

      sh 'docker build -t ' + dockerImage( architecture ) + ' .'

      if( repository != '' ) {
        // Push all built images relevant docker repository
        sh 'docker push ' + dockerImage( architecture )
      } // repository != ''
    }
  }
}

// Stages valid only if we have a repository set
if( repository != '' ) {

  // The multi arch image name
  multiImage = repository + imagePrefix + ':' + version

  // The manifest list for each built architecture
  manifests = architectures.collect { architecture -> dockerImage( architecture ) }
  manifests = manifests.join(' ')

  node( 'AMD64' ) {
    stage( "Multiarch Image" ) {
      // Create/amend the manifest with our architectures
      sh 'docker manifest create -a ' + multiImage + ' ' + manifests

      // For each architecture annotate them to be correct
      architectures.each {
        architecture -> sh 'docker manifest annotate' +
          ' --os linux' +
          ' --arch ' + goarch( architecture ) +
          ' ' + multiImage +
          ' ' + dockerImage( architecture )
      }

      // Publish the manifest
      sh 'docker manifest push -p ' + multiImage
    }
  }
}
