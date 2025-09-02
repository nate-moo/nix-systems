{ config, pkgs, lib, ...}:
{
  systemd.timers = {
    "rsync-backup" = {
      description = "Backs up important information with rsync";
      timerConfig = {
        OnCalendar = "weekly";
	Persistent = "true";
	Unit = "rsync-backup.service";
      };
    };
  };

  systemd.services = {
    "rsync-backup" = {
      description = "Backs up important information with rsync";
      script = "/home/nathan/.local/bin/rsync-backup";
    };
  };
}
