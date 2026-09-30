comm -23 <(sort -u employees.txt) <(awk '{print $2}' badge-swipes.log | sort -u) > never-badged.txt
comm -13 <(sort -u employees.txt) <(awk '{print $2}' badge-swipes.log | sort -u) > unknown-badges.txt
