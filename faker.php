<?php

require_once 'vendor/autoload.php';

function unique_multidimentional_array($array) {
  $tempArray = [];
  $keyArray = [];

  foreach($array as $val) {
    $key = $val[0] . $val[1];
    if (!in_array($key, $keyArray)) {
      $keyArray[] = $key;
      $tempArray[] = $val;
    }
  }
  return $tempArray;
}

$faker = Faker\Factory::create();

$usersFile = 'users.csv';
$clubsFile = 'clubs.csv';
$clubMembersFile = 'club_members.csv';

$userRange = 100_000;
$clubRange = 100_000;

$users = [];
for ($i = 1; $i <= $userRange; $i++) {
  $user = [];
  $user[] = $i;
  $user[] = $faker->firstName();
  $user[] = $faker->lastName();
  $users[$i] = $user;
}

file_put_contents($usersFile, '');
foreach ($users as $user) {
  file_put_contents($usersFile, implode(',', $user) . "\n", FILE_APPEND);
}

$clubs = [];
for ($i = 1; $i <= $clubRange; $i++) {
  $club = [];
  $club[] = $i;
  $club[] = $faker->company();
  $clubs[$i] = $club;
}

file_put_contents($clubsFile, '');
foreach ($clubs as $club) {
  file_put_contents($clubsFile, implode(',', $club) . "\n", FILE_APPEND);
}

$clubMembers = [];
for ($i = 0; $i <= $userRange / 2; $i++) {
  $clubMember = [];
  $clubMember[] = rand(1, $userRange);
  $clubMember[] = rand(1, $clubRange);
  $clubMembers[] = $clubMember;
}

$clubMembers = unique_multidimentional_array($clubMembers);

usort($clubMembers, function ($a, $b) {
        return [$a[0], $a[1]] <=> [$b[0], $b[1]];
    });

file_put_contents($clubMembersFile, '');
foreach ($clubMembers as $clubMember) {
  file_put_contents($clubMembersFile, implode(',', $clubMember) . "\n", FILE_APPEND);
}
