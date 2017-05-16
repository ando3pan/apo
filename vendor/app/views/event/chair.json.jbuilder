json.array!(@users) do |user|
    json.displayname user.displayname
    json.user_id     user.id
end
