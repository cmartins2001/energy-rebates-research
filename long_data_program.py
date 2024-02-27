'''
Connor Martins
EC 329
Term Project Data Processing Program
'''

import pandas as pd
import os


# Copy dataframe from Excel:
def make_df_copy(df, min_year=1997):
    df_copy = df.copy(deep=True)
    df_copy = df_copy[(df_copy['year'] >= min_year)]    # restrict nrg data to after '97 by default
    return df_copy


# Convert dataframe to long form:
def get_long_form(df, stub, i_var, j_var):
    df_long = pd.wide_to_long(df, [stub], i=i_var, j=j_var)
    return df_long


# Create the a state name and id dictionary:
states = ['AK','AL','AR','AZ','CA','CO','CT','DC','DE','FL','GA','HI',
          'IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN',
          'MO','MS','MT','NC','ND','NE','NH','NJ','NM','NV','NY','OH',
          'OL','OR','PA','RI','SC','SD','TN','TX','UT','VA','VT','WA',
          'WI','WV','WY']
state_nums = [i for i in range(1, 52)]
states_dict = dict(zip(state_nums, states))

# Create a dictionary with state ids and year passed:
treat_states = ['CA', 'DE', 'HI', 'MA', 'MD', 'ME', 
                'NH', 'NJ', 'NY', 'VT', 'WI']
treat_yrs = [2001, 2001, 2000, 2011, 2004, 2013, 
             2008, 2015, 2002, 2005, 2006]

# Make control and treatment group state id lists:
treatment_ids = [5, 9, 12, 20, 21, 22, 31, 32, 35, 47, 49]
control_ids = [i for i in range(1, 52) if i not in treatment_ids]
policy_yrs = dict(zip(treatment_ids, treat_yrs))

# Add state abbrev, treatment and policy year variables to first DF:
def add_treatment(df, stub, new_series_name, state_id_var):
    df = df.reset_index()
    df = (df
            .rename(columns={stub: new_series_name})
            .assign(state_nm=df[state_id_var].map(states_dict))
          )
    df = (df
          .assign(policy_yr=df['state_nm'].map(policy_yrs),
                  treat=df[state_id_var].apply(lambda x: 1 if x in treatment_ids else 0)
                 )
         )
    return df


# Join the series of all other dfs to the first:
def join_cols(df1, df_list, col_list):      # df1 = first dataframe in the list
    columns_to_join = col_list[1:]
    dfs_to_join = df_list[1:]
    dict1 = dict(zip(columns_to_join, dfs_to_join))
    for col, df in dict1.items():
        df1 = df1.join(df[col])
    return df1


# Add a time-to-treat variable to the final dataframe:
def time_to_treat_var(df, year_var='year', state_id_var='state'):
    # Use the policy years dictionary to add a policy yr for treated states:
    df['policy_yr'] = df[state_id_var].map(policy_yrs)

    # Make the time-to-treat variable:
    df['time_to_treat'] = df[year_var] - df['policy_yr']
    df['time_to_treat'].fillna(0, inplace=True)
    return df


# Export the final DF into an Excel document:
def make_xl(path, df, file_name):
    file_path = os.path.join(path, f'{file_name}.xlsx')
    return df.to_excel(file_path, index=True)


# The main() function:
def main():
    # Define file names, column names, and directory:
    directory = '/workspaces/energy-rebates-research/data'
    xls = ['auto_ren_nrg', 'auto_co2', 'auto_exp', 'auto_pop', 'auto_hdd', 'auto_cdd', 'auto_gdp']
    file_names = [os.path.join(directory, f'{name}.xlsx') for name in xls]
    col_names = ['ren_nrg', 'co2_em', 'exp_per_cap', 'population', 'hdd', 'cdd', 'state_gdp']

    # Generate a list of raw dataframes and copies:
    raw_dfs = [pd.read_excel(file) for file in file_names]
    raw_copies = [make_df_copy(raw_df) for raw_df in raw_dfs]

    # Generate lists of long-form dataframes:
    long_dfs = [get_long_form(raw_copy, 's', 'year', 'state') for raw_copy in raw_copies]

    # Make a dictionary with long dfs as the keys and new column names as the values:
    long_df_col_dict = dict(zip(col_names, long_dfs))

    # Generate a list of refined dataframes:
    refined_dfs = [add_treatment(long_df, 's', col_name, 'state') for col_name, long_df in long_df_col_dict.items()]

    # Join the dataframes from the refined list:
    joined_data = join_cols(df1=refined_dfs[0], df_list=refined_dfs, col_list=col_names)        
    
    # Add time-to-treat variable to joined DF:
    joined_data_final = time_to_treat_var(joined_data, 'year', state_id_var='state')     # see that function for the error

    # Export to XL:
    make_xl(directory, joined_data_final, 'automation_test')


if __name__ == '__main__':
    main()
