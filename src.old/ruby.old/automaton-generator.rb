#
# Generate state tables for a regular expression
#

# Example 1 (match either "abc" or "def"
regexp1 = "abc|def"


# Example 2:
# Two possible solution:
# - longest match ("abcd")
# - first match ("abc") ***** prefered for ORing *****
regexp2 = "abc|abcd"

# Example 3:
# longest match ("abcd")
regexp3 = "abc(d)?" 
