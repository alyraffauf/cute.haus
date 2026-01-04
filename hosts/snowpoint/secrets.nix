{self, ...}: {
  age.secrets = {
    navidrome.file = "${self.inputs.secrets}/navidrome.age";
    rclone-b2.file = "${self.inputs.secrets}/rclone/b2.age";
    restic-passwd.file = "${self.inputs.secrets}/restic-password.age";
    syncthingCert.file = "${self.inputs.secrets}/aly/syncthing/snowpoint/cert.age";
    syncthingKey.file = "${self.inputs.secrets}/aly/syncthing/snowpoint/key.age";
    tailscaleAuthKey.file = "${self.inputs.secrets}/tailscale/auth.age";
    vaultwarden.file = "${self.inputs.secrets}/vaultwarden.age";
  };
}
