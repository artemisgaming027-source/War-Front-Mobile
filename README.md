# WAR FRONT: MOBILE

Prototipe MOBA militer 3D untuk Android menggunakan Godot 4.3.

## Konsep
- Pertandingan offline 5 vs 5: 1 hero pemain + 4 sekutu bot melawan 5 bot lawan.
- Arena simetris dengan tiga lane, markas, bunker pertahanan, dan area perlindungan.
- Kamera top-down, kontrol sentuh, tombol tembak, dan kontrol keyboard untuk pengujian desktop.
- Grafis 3D berbasis mesh sederhana agar ringan dan mudah dikembangkan.

## Roster 5 hero awal
| Hero | Peran | Karakteristik |
|---|---|---|
| Assault | Penyerang serbaguna | Statistik seimbang |
| Sniper | Penembak jarak jauh | Jangkauan dan damage tinggi, HP rendah |
| Heavy | Tank garis depan | HP paling tinggi, gerak lebih lambat |
| Medic | Pendukung tim | Statistik support seimbang |
| Scout | Pengintai | Gerak cepat dan cooldown serangan singkat |

Kelima profil sudah dipakai oleh unit pemain dan bot, dengan perbedaan HP, kecepatan gerak, damage, jangkauan, dan jeda serangan.

## Membuka proyek
1. Unduh atau clone repositori ini.
2. Buka folder proyek melalui Godot 4.3.
3. Jalankan scene scenes/Main.tscn.

## Status
Ini masih prototipe gameplay. Skill aktif/ultimate, pemilihan hero dari menu, minion lane, sistem item, audio, animasi/model karakter final, dan multiplayer online belum termasuk. APK belum siap diuji sampai ekspor Android berhasil dan artefak APK tersedia.
