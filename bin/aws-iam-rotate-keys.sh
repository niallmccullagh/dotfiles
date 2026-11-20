#!/usr/bin/env bash

## PREREQUISITES CHECK

# `exists` for commands
exists() {
  command -v "$1" >/dev/null 2>&1
}

# is AWS CLI installed?
if ! exists aws ; then
  printf "\n******************************************************************************************************************************\n\
This script requires the AWS CLI. See the details here: http://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html\n\
******************************************************************************************************************************\n\n"
  exit 1
fi

# check for ~/.aws directory, and ~/.aws/{config|credentials} files
if [ ! -d ~/.aws ]; then
  echo
  echo -e "'~/.aws' directory not present.\nMake sure it exists, and that you have at least one profile configured\nusing the 'config' and 'credentials' files within that directory."
  echo
  exit 1
fi

if [[ ! -f ~/.aws/config && ! -f ~/.aws/credentials ]]; then
  echo
  echo -e "'~/.aws/config' and '~/.aws/credentials' files not present.\nMake sure they exist. See http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html for details on how to set them up."
  echo
  exit 1
elif [ ! -f ~/.aws/config ]; then
  echo
  echo -e "'~/.aws/config' file not present.\nMake sure it and '~/.aws/credentials' files exists. See http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html for details on how to set them up."
  echo
  exit 1
elif [ ! -f ~/.aws/credentials ]; then
  echo
  echo -e "'~/.aws/credentials' file not present.\nMake sure it and '~/.aws/config' files exists. See http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html for details on how to set them up."
  echo
  exit 1
fi

CREDFILE=~/.aws/credentials
# check that at least one profile is configured
ONEPROFILE="false"
while IFS='' read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^\[(.*)\].* ]] &&
    profile_ident=${BASH_REMATCH[1]}

    if [ -n "$profile_ident" ]; then
      ONEPROFILE="true"
    fi
done < $CREDFILE


if [[ "$ONEPROFILE" = "false" ]]; then
  echo
  echo -e "NO CONFIGURED AWS PROFILES FOUND.\nPlease make sure you have '~/.aws/config' (profile configurations),\nand '~/.aws/credentials' (profile credentials) files, and at least\none configured profile. For more info, see AWS CLI documentation at:\nhttp://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html"
  echo

else

  # Check OS for some supported platforms
  OS="`uname`"
  case $OS in
    'Linux')
      OS='Linux'
      ;;
    'Darwin')
      OS='macOS'
      ;;
    *)
      OS='unknown'
      echo
      echo "** NOTE: THIS SCRIPT HAS NOT BEEN TESTED ON YOUR CURRENT PLATFORM."
      echo
      ;;
  esac

  ## PREREQS PASSED; PROCEED..

  declare -a cred_profiles
  declare -a cred_allprofiles
  declare -a cred_profile_arn
  declare -a cred_profile_user
  declare -a cred_profile_keys
  declare -a key_status
  cred_profilecounter=0

  TODAY=`date "+%Y-%m-%d"`

  echo "Please wait..."

  # get profiles, keys (and their ages) for selection
  while IFS='' read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^\[(.*)\].* ]] &&
    profile_ident=${BASH_REMATCH[1]}

    # only process if profile identifier is present,
    # and if it's not a mfasession profile
    if [ "$profile_ident" != "" ] &&
       ! [[ "$profile_ident" =~ -mfasession$ ]]; then

      cred_profiles[$cred_profilecounter]=$profile_ident

      # get user ARN; this should be always available if the access_key_id is valid
      user_arn="$(aws sts get-caller-identity --profile "$profile_ident" --output text --query 'Arn' 2>&1)"
      if [[ "$user_arn" =~ ^arn:aws ]]; then
         cred_profile_arn[$cred_profilecounter]=$user_arn
      elif [[ "$user_arn" =~ InvalidClientTokenId ]]; then
         cred_profile_arn[$cred_profilecounter]="INVALID"
      else
         cred_profile_arn[$cred_profilecounter]=""
      fi

      # get the actual username (may be different from the arbitrary profile ident)
      if [[ "${cred_profile_arn[$cred_profilecounter]}" =~ ^arn:aws ]]; then
        [[ "$user_arn" =~ ([^/]+)$ ]] &&
          cred_profile_user[$cred_profilecounter]="${BASH_REMATCH[1]}"
      elif [ "${cred_profile_arn[$cred_profilecounter]}" = "INVALID" ]; then
          cred_profile_user[$cred_profilecounter]="CHECK CREDENTIALS!"
      else
          cred_profile_user[$cred_profilecounter]=""
      fi

      # get access keys & their ages for the profile
      key_status_accumulator=""

      if [ "${cred_profile_arn[$cred_profilecounter]}" != "INVALID" ]; then

        key_status_array=(`aws iam list-access-keys --profile "$profile_ident" --output json --query AccessKeyMetadata[*].[Status,CreateDate,AccessKeyId] | grep -A2 ctive | awk -F\" '{print $2}'`)

        s_no=0
        for s in ${key_status_array[@]}; do
          if [[ "$s" == "Active" || "$s" == "Inactive" ]]; then

            if [ "$s" == "Active" ]; then
              statusword="  Active"
            else
              statusword="Inactive"
            fi

            let "s_no++"
            kcd=`echo ${key_status_array[$s_no]} | sed 's/T/ /' | awk '{print $1}'`
            let  keypos=${s_no}+1
            if [ "$OS" = "macOS" ]; then
              key_status_accumulator="   ${statusword} key ${key_status_array[$keypos]} is $(((`date -jf %Y-%m-%d $TODAY +%s` - `date -jf %Y-%m-%d $kcd +%s`)/86400)) days old\n${key_status_accumulator}"
            else
              key_status_accumulator="   ${statusword} key ${key_status_array[$keypos]} is $(((`date -d "$TODAY" "+%s"` - `date -d "$kcd" "+%s"`)/86400)) days old\n${key_status_accumulator}"
            fi
          else
            let "s_no++"
          fi
        done

      fi
      cred_profile_keys[$cred_profilecounter]=$key_status_accumulator

## DEBUG
#     echo "PROFILE IDENT: $profile_ident"
#     echo "USER ARN: ${cred_profile_arn[$cred_profilecounter]}"
#     echo "USER NAME: ${cred_profile_user[$cred_profilecounter]}"
#     echo "MFA ARN: ${mfa_arns[$cred_profilecounter]}"

      # erase variables & increase iterator for the next iteration
      user_arn=""
      profile_ident=""
      profile_username=""

      cred_profilecounter=$(($cred_profilecounter+1))

    fi
  done < $CREDFILE

  # create profile selections for key rotation
  echo "CONFIGURED AWS PROFILES AND THEIR ASSOCIATED KEYS:"
  echo
  SELECTR=0
  ITER=1
  for i in "${cred_profiles[@]}"
  do
    if [ "${cred_profile_arn[$SELECTR]}" = "INVALID" ]; then
      echo "X: $i (${cred_profile_user[$SELECTR]})"
    else
      echo "${ITER}: $i (${cred_profile_user[$SELECTR]})"
      printf "${cred_profile_keys[$SELECTR]}"
    fi
    echo
    let ITER=${ITER}+1
    let SELECTR=${SELECTR}+1
  done

  # prompt for profile selection
  printf "SELECT THE PROFILE WHOSE KEYS YOU WANT TO ROTATE (or press [ENTER] to abort): "
  read -r selprofile

  # process the selection
  if [ "$selprofile" != "" ]; then
    #capture the numeric part of the selection
      [[ $selprofile =~ ^([[:digit:]]+) ]] &&
      selprofile_check="${BASH_REMATCH[1]}"
      if [ "$selprofile_check" != "" ]; then

        # if the numeric selection was found,
        # translate it to the array index and validate
        let actual_selprofile=${selprofile_check}-1

        profilecount=${#cred_profiles[@]}
        if [[ $actual_selprofile -ge $profilecount ||
           $actual_selprofile -lt 0 ]]; then
          # a selection outside of the existing range was specified
          echo
          echo "There is no profile '${selprofile}'."
          echo
          exit 1
        fi

        # a base profile was selected
        if [[ $selprofile =~ ^[[:digit:]]+$ ]]; then

          if [ "${cred_profile_arn[$actual_selprofile]}" = "INVALID" ]; then
            echo
            echo "PROFILE \"${cred_profiles[$actual_selprofile]}\" HAS INVALID ACCESS KEYS. Cannot proceed."
            echo
            exit 1
          else
            echo
            echo "SELECTED PROFILE: ${cred_profiles[$actual_selprofile]}"
            final_selection="${cred_profiles[$actual_selprofile]}"
            final_selection_name="${cred_profile_user[$actual_selprofile]}"
            echo "SELECTED USER: $final_selection_name"
          fi
        else
          # non-acceptable characters were present in the selection
            echo
            echo "There is no profile '${selprofile}'."
            echo
            exit 1
        fi

      else
        # no numeric part in selection
        echo
        echo "There is no profile '${selprofile}'."
        echo
        exit 1
      fi

    else
      # empty selection; exit
      echo
      echo "Aborting. No changes were made."
      echo
      exit 1
    fi

  fi

  # does mfasession profile exist for the chosen profile?
  mfaprofile_exists=false
  ITERATR=0
  while IFS='' read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^\[(.*)\].* ]] &&
      all_profile_ident=${BASH_REMATCH[1]}
      if [[ $all_profile_ident != "" &&
            "$all_profile_ident" == "${final_selection}-mfasession" ]]; then
        mfaprofile_exists=true
        break
        let "ITERATR++"
      fi
      all_profile_ident=""
  done < $CREDFILE

  # mfasession exists -- use it?
  use_mfaprofile=false
  if [ "$mfaprofile_exists" = "true" ]; then

    echo
    echo "-----------------------------------------------------------------"
    echo
    echo -e "An MFA profile ('${final_selection}-mfasession') exists\nfor the profile whose keys you have chosen to rotate."
    echo
    echo -e "Do you want to use it to execute the key rotation for\nthe profile you selected? If MFA is being enforced\nfor the profile selected for rotation, it may not be\nauthorized to carry out its own key rotation and the MFA\nprofile may need to be used instead."
    echo
    echo -e "Note that the MFA profile session MUST BE ACTIVE for it\nto work. Select Abort below if you need to activate\nthe MFA session before proceeding."
    echo

    while true; do
      read -p "Use the MFA profile to authorize the key rotation? Yes/No/Abort " ync
      case $ync in
          [Yy]* ) use_mfaprofile=true; break;;
          [Nn]* ) break;;
          [Aa]* ) echo; exit;;
          * ) echo "Please answer (y)es, (n)o, or (a)bort.";;
      esac
    done
  fi

  if [ "$use_mfaprofile" = "false" ]; then
    selected_authprofile=$final_selection
  else
    selected_authprofile=${final_selection}-mfasession

    echo "Please wait..."

    # check for expired MFA session
    EXISTING_KEYS_CREATEDATES=$(aws iam list-access-keys --query 'AccessKeyMetadata[].CreateDate' --output text --profile "$selected_authprofile" 2>&1)
    if [[ "$EXISTING_KEYS_CREATEDATES" =~ ExpiredToken ]]; then
      echo -e "\nYour MFA token has expired. Refresh your MFA session\nfor the profile '${final_selection}', and try again.\n\nAborting.\n"
      exit 1
    fi

  fi
  echo "Selected Auth Profile: $selected_authprofile"
  echo
### BEGIN KEY ROTATION SEQUENCE

  profile_uses_credentials() {
    local profile=$1 access_key_id=$2 secret_access_key=$3
    local resolved expected
    resolved=$(aws configure export-credentials --profile "$profile" --format env-no-export) || return 1
    printf -v expected 'AWS_ACCESS_KEY_ID=%s\nAWS_SECRET_ACCESS_KEY=%s' "$access_key_id" "$secret_access_key"
    [[ "$resolved" == "$expected" ]]
  }

  write_profile_credentials() {
    local profile=$1 access_key_id=$2 secret_access_key=$3
    local status=0
    aws configure set aws_access_key_id "$access_key_id" --profile "$profile" || status=1
    aws configure set aws_secret_access_key "$secret_access_key" --profile "$profile" || status=1
    return "$status"
  }

  echo
  echo "Verifying that AWS CLI has configured credentials ..."
  ORIGINAL_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$final_selection")
  ORIGINAL_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$final_selection")
  ORIGINAL_ARN=${cred_profile_arn[$actual_selprofile]}
  if [[ "$ORIGINAL_ARN" != arn:aws*:iam::*:user/* ||
        -z "$ORIGINAL_ACCESS_KEY_ID" || -z "$ORIGINAL_SECRET_ACCESS_KEY" ]]; then
    echo "The selected profile must contain working long-term IAM user credentials." >&2
    exit 1
  fi
  if ! profile_uses_credentials "$final_selection" "$ORIGINAL_ACCESS_KEY_ID" "$ORIGINAL_SECRET_ACCESS_KEY"; then
    echo "Could not verify the selected profile's stored credentials. AWS CLI v2 is required." >&2
    exit 1
  fi

  if [[ "$selected_authprofile" != "$final_selection" ]]; then
    if ! auth_arn=$(aws sts get-caller-identity --profile "$selected_authprofile" --output text --query Arn) ||
       [[ "$auth_arn" != "$ORIGINAL_ARN" ]]; then
      echo "The MFA profile must authenticate as the same IAM user as the selected profile." >&2
      exit 1
    fi
  fi

  if ! active_key=$(aws iam list-access-keys --profile "$selected_authprofile" --output text \
    --query "AccessKeyMetadata[?AccessKeyId=='$ORIGINAL_ACCESS_KEY_ID' && Status=='Active'].AccessKeyId") ||
    [[ "$active_key" != "$ORIGINAL_ACCESS_KEY_ID" ]]; then
    echo "Could not confirm that the configured key is active for this IAM user." >&2
    exit 1
  fi

  if ! existing_key_dates=$(aws iam list-access-keys --query 'AccessKeyMetadata[].CreateDate' --output text --profile "$selected_authprofile") ||
    [[ -z "$existing_key_dates" || "$existing_key_dates" == None ]]; then
    echo "Could not list the IAM user's existing keys." >&2
    exit 1
  fi
  EXISTING_KEYS_CREATEDATES=($existing_key_dates)
  NUM_EXISTING_KEYS=${#EXISTING_KEYS_CREATEDATES[@]}
  if [ ${NUM_EXISTING_KEYS} -lt 2 ]; then
    echo "You have only one existing key. Now proceeding with new key creation."

  else
    echo "You have two keys (maximum number). We must make space ..."

    IFS=$'\n' sorted_createdates=($(sort <<<"${EXISTING_KEYS_CREATEDATES[*]}"))
    unset IFS

    echo "Now acquiring data for the older key ..."
    OLDER_KEY_CREATEDATE="${sorted_createdates[0]}"
    OLDER_KEY_ID=$(aws iam list-access-keys --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].AccessKeyId" --output text --profile "$selected_authprofile")
    OLDER_KEY_STATUS=$(aws iam list-access-keys --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].Status" --output text --profile "$selected_authprofile")

    echo "Now acquiring data for the newer key ..."
    NEWER_KEY_CREATEDATE="${sorted_createdates[1]}"
    NEWER_KEY_ID=$(aws iam list-access-keys --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].AccessKeyId" --output text --profile "$selected_authprofile")
    NEWER_KEY_STATUS=$(aws iam list-access-keys --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].Status" --output text --profile "$selected_authprofile")

    key_in_use=""
    allow_older_key_delete=false
    allow_newer_key_delete=false
    if [ ${OLDER_KEY_STATUS} = "Active" ] &&
       [ ${NEWER_KEY_STATUS} = "Active" ] &&
       [ "${NEWER_KEY_ID}" = "${ORIGINAL_ACCESS_KEY_ID}" ]; then
      # both keys are active, newer key is in use
      key_in_use="newer"
      allow_older_key_delete=true
      key_id_can_delete=$OLDER_KEY_ID
      key_id_remaining=$NEWER_KEY_ID
    elif [ ${OLDER_KEY_STATUS} = "Active" ] &&
         [ ${NEWER_KEY_STATUS} = "Active" ] &&
         [ "${OLDER_KEY_ID}" = "${ORIGINAL_ACCESS_KEY_ID}" ]; then
      # both keys are active, older key is in use
      key_in_use="older"
      allow_newer_key_delete=true
      key_id_can_delete=$NEWER_KEY_ID
      key_id_remaining=$OLDER_KEY_ID
    elif [ ${OLDER_KEY_STATUS} = "Inactive" ] &&
         [ ${NEWER_KEY_STATUS} = "Active" ]; then
      # newer key is active and in use
      key_in_use="newer"
      allow_older_key_delete=true
      key_id_can_delete=$OLDER_KEY_ID
      key_id_remaining=$NEWER_KEY_ID
    elif [ ${OLDER_KEY_STATUS} = "Active" ] &&
         [ ${NEWER_KEY_STATUS} = "Inactive" ]; then
      # older key is active and in use
      key_in_use="older"
      allow_newer_key_delete=true
      key_id_can_delete=$NEWER_KEY_ID
    else
      echo "You don't have keys I can delete to make space for the new key. Please delete a key manually and then try again."
      echo "Aborting."
      exit 1
    fi

  fi

  if [ "${allow_older_key_delete}" = "true" ] ||
     [ "${allow_newer_key_delete}" = "true" ]; then
    echo "To proceed you must delete one of your two existing keys; they are listed below:"
    echo
    echo "OLDER EXISTING KEY (${OLDER_KEY_STATUS}, created on ${OLDER_KEY_CREATEDATE}):"
    echo -n "Key Access ID: ${OLDER_KEY_ID} "
    if [ "${allow_older_key_delete}" = "true" ]; then
      echo "(this key can be deleted)"
    elif [ "${key_in_use}" = "older" ]; then
      echo "(this key is currently your active key)"
    fi
    echo
    echo "NEWER EXISTING KEY (${NEWER_KEY_STATUS}, created on ${NEWER_KEY_CREATEDATE}):"
    echo -n "Key Access ID: ${NEWER_KEY_ID} "
    if [ "${allow_newer_key_delete}" = "true" ]; then
      echo "(this key can be deleted)"
    elif [ "${key_in_use}" = "newer" ]; then
      echo "(this key is currently your active key)"
    fi
    echo
    echo
    echo "Enter below the Access Key ID of the key to delete, or leave empty to cancel, then press enter."
    read key_in

    if [[ -n "$key_in" && "$key_in" == "$key_id_can_delete" && "$key_in" != "$ORIGINAL_ACCESS_KEY_ID" ]]; then
      echo "Now deleting the key ${key_id_can_delete}"
      aws iam delete-access-key --access-key-id "${key_id_can_delete}" --profile "$selected_authprofile"
      if [ $? -ne 0 ]; then
        echo
        echo "Could not delete the access keyID ${key_id_can_delete}. Cannot proceed."
        if [ "$use_mfaprofile" = "true" ]; then
          echo -e "\nNOTE: If you see access denied/not authorized error above,\nyour MFA session may have expired.\n"
        else
          echo -e "\nNOTE: If you see access denied/not authorized error above, you may need\nto use MFA session to authorize the key rotation.\n"
        fi
        echo "Aborting."
        exit 1
      fi
    elif [ "${key_in}" = "" ]; then
      echo Aborting.
      exit 1
    else
      echo "The input did not match the Access Key ID of the key that can be deleted. Run the script again to retry."
      echo "Aborting."
      exit 1
    fi
  fi

  echo
  echo "Creating a new access key for the current IAM user ..."
  if ! new_key=$(aws iam create-access-key --profile "$selected_authprofile" --output text \
    --query 'AccessKey.[AccessKeyId,SecretAccessKey]'); then
    echo "Could not create a new access key." >&2
    exit 1
  fi
  IFS=$'\t' read -r NEW_AWS_ACCESS_KEY_ID NEW_AWS_SECRET_ACCESS_KEY <<< "$new_key"
  if [[ -z "$NEW_AWS_ACCESS_KEY_ID" || "$NEW_AWS_ACCESS_KEY_ID" == None ||
        -z "$NEW_AWS_SECRET_ACCESS_KEY" || "$NEW_AWS_SECRET_ACCESS_KEY" == None ]]; then
    echo "Could not read the new access key from the AWS response." >&2
    exit 1
  fi

  restore_profile_and_abort() {
    trap - HUP INT TERM
    echo "Restoring the original credentials for '$final_selection'." >&2
    if write_profile_credentials "$final_selection" "$ORIGINAL_ACCESS_KEY_ID" "$ORIGINAL_SECRET_ACCESS_KEY" &&
      profile_uses_credentials "$final_selection" "$ORIGINAL_ACCESS_KEY_ID" "$ORIGINAL_SECRET_ACCESS_KEY"; then
      echo "Original credentials restored." >&2
    else
      echo "Could not restore or verify the original credentials. Check the credentials for '$final_selection'." >&2
    fi
    echo "The original key was kept. Review the new IAM access key '$NEW_AWS_ACCESS_KEY_ID' before retrying." >&2
    exit 1
  }

  trap restore_profile_and_abort HUP INT TERM
  echo "Configuring the new key for '$final_selection' ..."
  if ! write_profile_credentials "$final_selection" "$NEW_AWS_ACCESS_KEY_ID" "$NEW_AWS_SECRET_ACCESS_KEY" ||
     ! profile_uses_credentials "$final_selection" "$NEW_AWS_ACCESS_KEY_ID" "$NEW_AWS_SECRET_ACCESS_KEY"; then
    echo "Could not install the new credentials for '$final_selection'." >&2
    restore_profile_and_abort
  fi

  echo "Verifying the new key as '$final_selection' ..."
  verified=false
  for (( attempt=1; attempt<=20; attempt++ )); do
    if new_arn=$(aws sts get-caller-identity --profile "$final_selection" --output text --query Arn); then
      if [[ "$new_arn" == "$ORIGINAL_ARN" ]]; then
        verified=true
      fi
      break
    fi
    if (( attempt < 20 )); then
      sleep 10
    fi
  done
  if [[ "$verified" != true ]] ||
     ! profile_uses_credentials "$final_selection" "$NEW_AWS_ACCESS_KEY_ID" "$NEW_AWS_SECRET_ACCESS_KEY"; then
    echo "Could not verify the new credentials as the original IAM user." >&2
    restore_profile_and_abort
  fi
  trap - HUP INT TERM

  echo "Deleting the previously active access key ..."
  if ! aws iam delete-access-key --access-key-id "$ORIGINAL_ACCESS_KEY_ID" --profile "$selected_authprofile"; then
    echo "Could not confirm deletion of the old key '$ORIGINAL_ACCESS_KEY_ID'. The verified new key remains configured." >&2
    exit 1
  fi

  echo "Rotated the key for profile '$final_selection' (IAM user '$final_selection_name')."
  echo "Switched from access key $ORIGINAL_ACCESS_KEY_ID to $NEW_AWS_ACCESS_KEY_ID."
  exit 0
