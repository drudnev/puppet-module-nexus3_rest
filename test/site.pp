class custom::nexus (
  Optional[Hash] $repositories = {},
  Optional[Hash] $repository_groups = {},
){
    ensure_resources( 'nexus3_repository', $repositories )
    ensure_resources( 'nexus3_repository_group', $repository_groups )
}


node default {
  include custom::nexus
}
