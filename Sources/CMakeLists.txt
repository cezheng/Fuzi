add_library(Fuzi
  Document.swift
  Element.swift
  Error.swift
  Helpers.swift
  Node.swift
  NodeSet.swift
  Queryable.swift)

target_link_libraries(Fuzi PUBLIC
  LibXml2)
