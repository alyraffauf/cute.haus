locals {
  cute_haus_solaceon_a = toset([
    "cute.haus",
    "audiobookshelf.cute.haus",
    "jellyfin.cute.haus",
    "kuma.cute.haus",
    "immich.cute.haus",
    "ombi.cute.haus",
    "plex.cute.haus",
    "status.cute.haus",
    "vault.cute.haus",
  ])
}

resource "cloudflare_dns_record" "cute_haus_a_solaceon" {
  for_each = local.cute_haus_solaceon_a
  zone_id  = local.zones.cute_haus
  name     = each.value
  type     = "A"
  content  = local.hosts.solaceon
  proxied  = true
  ttl      = 1
  tags     = []
  settings = {}
}

resource "cloudflare_dns_record" "cute_haus_couchdb_a" {
  zone_id  = local.zones.cute_haus
  name     = "couchdb.cute.haus"
  type     = "A"
  content  = "34.203.252.172"
  proxied  = true
  ttl      = 1
  tags     = []
  settings = {}
}

resource "cloudflare_dns_record" "cute_haus_navidrome_a" {
  zone_id  = local.zones.cute_haus
  name     = "navidrome.cute.haus"
  type     = "A"
  content  = "107.140.155.124"
  proxied  = true
  ttl      = 1
  tags     = []
  settings = {}
}

resource "cloudflare_dns_record" "cute_haus_www_cname" {
  zone_id = local.zones.cute_haus
  name    = "www.cute.haus"
  type    = "CNAME"
  content = "cute.haus"
  proxied = true
  ttl     = 1
  tags    = []
  settings = {
    flatten_cname = false
  }
}

resource "cloudflare_dns_record" "cute_haus_atproto_txt" {
  zone_id  = local.zones.cute_haus
  name     = "_atproto.cute.haus"
  type     = "TXT"
  content  = "\"did=did:plc:rkos3laovknh53dwtdguu27n\""
  proxied  = false
  ttl      = 1
  tags     = []
  settings = {}
}

resource "cloudflare_dns_record" "cute_haus_apex_google_verify_txt" {
  zone_id  = local.zones.cute_haus
  name     = "cute.haus"
  type     = "TXT"
  content  = "\"google-site-verification=jN1nPjBAhwmZKG9jNUV631cEC_k7rZhlQxncMablr-E\""
  proxied  = false
  ttl      = 3600
  tags     = []
  settings = {}
}
