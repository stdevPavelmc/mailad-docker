<?php
$config['imap_conn_options'] = array(
    'ssl' => [
         'verify_peer'       => true,
         'allow_self_signed' => true,
//         'peer_name'         =>  'xyz.mailad.cu',
         'verfify_peer_name' => false,
    ],
    );

    $config['smtp_conn_options'] = array(
      'ssl'=> array(
          'verify_peer'      => true,
//          'peer_name'        =>  'xyz.mailad.cu',
          'allow_self_signed'=> true,
          'verify_peer_name' => false,
      ),
    );

$config['plugins'] = [
    'archive',
    'zipdownload',
];



