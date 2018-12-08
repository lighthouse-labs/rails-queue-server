class TeacherSerializer < UserSerializer

  format_keys :lower_camel

  attributes :specialties,
             :bio,
             :quirky_fact,
             :slack

end
