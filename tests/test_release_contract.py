"""Static build contracts; not a substitute for actual ARM64 boot or Luanti gameplay."""
import os
import stat
import subprocess
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]


class ProvisioningContracts(unittest.TestCase):
    def test_system_installer_dry_run_no_side_effects(self):
        proc=subprocess.run(['bash', str(ROOT/'installer/system-install.sh')], capture_output=True,text=True,check=True,timeout=6)
        self.assertIn('DRY RUN ONLY',proc.stdout)
        self.assertIn('atlas, nova',proc.stdout)
    def test_app_installer_dry_run(self):
        proc=subprocess.run(['bash',str(ROOT/'installer/install-apps.sh')],capture_output=True,text=True,check=True,timeout=6)
        self.assertIn('DRY RUN',proc.stdout)
        self.assertIn('luanti-game-minetest',proc.stdout)
    def test_offline_guard_dry_run(self):
        proc=subprocess.run(['bash',str(ROOT/'installer/offline-guard.sh')],capture_output=True,text=True,check=True,timeout=6)
        self.assertIn('DRY RUN',proc.stdout)
        self.assertIn('atlas/nova',proc.stdout)
    def test_no_blanket_user_sudo_or_autologin(self):
        code=(ROOT/'installer/system-install.sh').read_text()
        self.assertIn('chmod 0700 "/home/$u"',code)
        self.assertIn('install -d -m 2770 -o root -g wonderforge',code)
        self.assertIn('passwd --lock "$u"',code)
        self.assertNotIn('NOPASSWD',code)
        self.assertNotIn('autologin-user=',code)
    def test_service_local_only_and_sandboxed_browser(self):
        service=(ROOT/'os/systemd/wonderforge.service').read_text()
        runner=(ROOT/'scripts/wonderforge-launch').read_text()
        self.assertIn('server.py --user-port',service)
        self.assertIn('NoNewPrivileges=true',service)
        self.assertIn("'127.0.0.1'",(ROOT/'server.py').read_text())
        self.assertIn('--app=',runner)
        self.assertNotIn("'--no-sandbox'",runner)


class LuantiAndImageContracts(unittest.TestCase):
    def test_luanti_world_and_six_portals(self):
        folder=ROOT/'os/worlds/WonderForge/worldmods/wonderforge'
        lua=(folder/'init.lua').read_text()
        self.assertTrue((folder/'mod.conf').is_file())
        self.assertIn('mg_name = singlenode',(ROOT/'os/worlds/WonderForge/world.mt').read_text())
        for name in ('sky','robot','crystal','red','echo','code'):
            self.assertIn('id="'+name+'"',lua)
            self.assertTrue((folder/'textures'/('wonderforge_'+name+'.png')).is_file())
        for command in ('forge','forgehome'):
            self.assertIn('register_chatcommand("'+command+'"',lua)
        self.assertIn('register_on_generated',lua)
        self.assertIn('VoxelArea:new',lua)
    def test_layer_recipe_yaml(self):
        try: import yaml
        except ImportError: self.skipTest('PyYAML not installed in minimal target (only needed for dev lint)')
        cfg=yaml.safe_load((ROOT/'image/wonderforge-pi4.yaml').read_text())
        self.assertEqual(cfg['device']['layer'],'rpi4')
        self.assertEqual(cfg['layer']['maker'],'wonderforge-maker')
        self.assertIn('luanti',cfg['packages'])
    def test_image_builder_not_dangerous_by_default(self):
        proc=subprocess.run(['bash',str(ROOT/'image/build-image.sh')],capture_output=True,text=True,check=True,timeout=6)
        self.assertIn('DRY RUN ONLY',proc.stdout)
        self.assertNotIn('dd if=',(ROOT/'image/build-image.sh').read_text())
        self.assertIn('PIN=',(ROOT/'image/build-image.sh').read_text())
    def test_shell_syntax(self):
        scripts=list((ROOT/'installer').glob('*.sh'))+list((ROOT/'image').glob('*.sh'))+list((ROOT/'scripts').glob('*.sh'))
        proc=subprocess.run(['bash','-n',*map(str,scripts)],capture_output=True,text=True,timeout=5)
        self.assertEqual(proc.returncode,0,proc.stderr)


if __name__=='__main__': unittest.main()
