function testMongoScript {
    mongo <<EOF
    use mydb
    db.leads.findOne()
    db.leads.find().count()
EOF
}
also possibility to use mongo with --eval flag
